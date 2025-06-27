import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct AddListing: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Tab                    // Coming from MainTabView

    // MARK: - Form Fields
    @State private var title             = ""
    @State private var price             = ""
    @State private var selectedCondition = "New"
    @State private var description       = ""
    @State private var location          = ""
    @State private var city              = ""
    @State private var selectedProvince  = "Province"
    @State private var hideAddress       = false

    // MARK: - Media
    @State private var selectedImage: UIImage?       // one photo
    @State private var selectedVideoURL: URL?        // one video
    @State private var showImagePicker = false
    @State private var showVideoPicker = false

    // MARK: - UI State
    @State private var showCancelDialog = false
    @State private var isPublishing     = false
    @State private var showAlert        = false
    @State private var alertMessage     = ""

    private let conditions = ["New", "Used - Like New", "Used - Good", "Used - Fair"]
    private let provinces  = ["Province","AB","BC","MB","NB","NL","NS","NT",
                              "NU","ON","PE","QC","SK","YT"]
    
    func resetForm() { // to reset once user post or dicard the listing and goes to the home page.
               title = ""
              price = ""
              selectedCondition = "New"
              description = ""
              location = ""
              city = ""
              selectedProvince = "Province"    }

    // MARK: - Body -----------------------------------------------------------
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    mediaUploadSection
                    mediaPreview
                    mediaCount

                    groupTextField("Title",         text: $title)
                    groupTextField("Price",         text: $price, keyboard: .numberPad)
                    conditionPicker
                    descriptionField
                    groupTextField("Location",      text: $location)
                    groupTextField("City",          text: $city)
                    provinceMenu
                    Toggle("Hide Property Address", isOn: $hideAddress)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Listing details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { topToolbar }
            .confirmationDialog("Discard Listing?",
                                isPresented: $showCancelDialog) { discardButtons }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(videoURL: $selectedVideoURL)
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: { Text(alertMessage) }
        }
    }

    // MARK: - View Builders --------------------------------------------------
    private var mediaUploadSection: some View {
        HStack(spacing: 16) {
            uploadButton(icon: "video.badge.plus",
                         label: "Add video") { showVideoPicker = true }
            uploadButton(icon: "photo.on.rectangle.angled",
                         label: "Add photo") { showImagePicker = true }
        }
    }

    private var mediaPreview: some View {
        Group {
            if let img = selectedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
            }
        }
    }

    private var mediaCount: some View {
        Text("Photos: \(selectedImage == nil ? 0 : 1)/1  •  Videos: \(selectedVideoURL == nil ? 0 : 1)/1")
            .font(.caption)
            .foregroundColor(.gray)
    }

    private func groupTextField(_ placeholder: String,
                                text: Binding<String>,
                                keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }

    private var conditionPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Condition")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(conditions, id: \.self) { cond in
                        Button(cond) { selectedCondition = cond }
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedCondition == cond ? Color.blue.opacity(0.25)
                                                                 : Color(.systemGray5))
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var descriptionField: some View {
        TextField("Description (recommended)", text: $description, axis: .vertical)
            .lineLimit(3...6)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }

    private var provinceMenu: some View {
        Menu {
            ForEach(provinces, id: \.self) { prov in
                Button(prov) { selectedProvince = prov }
            }
        } label: {
            HStack {
                Text(selectedProvince == "Province" ? "Select Province" : selectedProvince)
                    .foregroundColor(selectedProvince == "Province" ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }

    private func uploadButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon).font(.system(size: 30))
                Text(label).font(.footnote).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
        }
    }

    // MARK: - Toolbar / Confirmation ----------------------------------------
    @ToolbarContentBuilder
    private var topToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showCancelDialog = true } label: {
                Label("Cancel", systemImage: "chevron.left")
            }
            .disabled(isPublishing)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: handlePublish) {
                if isPublishing {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Text("Publish")
                }
            }
            .disabled(isPublishing)
        }
    }

    private var discardButtons: some View {
        Group {
            Button("Discard", role: .destructive) {
                selectedTab = .home
                resetForm()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Publish Flow ---------------------------------------------------
    private func handlePublish() {
        if let error = validateForm() {
            showError(error); return
        }
        isPublishing = true

        switch (selectedImage, selectedVideoURL) {
        case let (img?, vid?):
            uploadBoth(img, vid)
        case let (img?, nil):
            uploadImageOnly(img)
        case let (nil, vid?):
            uploadVideoOnly(vid)
        default:
            showError("Please add at least one photo or video")
        }
    }

    private func uploadBoth(_ image: UIImage, _ videoURL: URL) {
        StorageService.shared.uploadImage(image: image) { imgRes in
            switch imgRes {
            case .success(let imgURL):
                StorageService.shared.uploadVideo(fileURL: videoURL) { vidRes in
                    switch vidRes {
                    case .success(let vidURL): saveListing(imgURL, vidURL)
                    case .failure(let e): showError("Video upload failed: \(e.localizedDescription)")
                    }
                }
            case .failure(let e): showError("Image upload failed: \(e.localizedDescription)")
            }
        }
    }

    private func uploadImageOnly(_ image: UIImage) {
        StorageService.shared.uploadImage(image: image) { res in
            switch res {
            case .success(let imgURL): saveListing(imgURL, nil)
            case .failure(let e):      showError("Image upload failed: \(e.localizedDescription)")
            }
        }
    }

    private func uploadVideoOnly(_ url: URL) {
        StorageService.shared.uploadVideo(fileURL: url) { res in
            switch res {
            case .success(let vidURL): saveListing(nil, vidURL)
            case .failure(let e):      showError("Video upload failed: \(e.localizedDescription)")
            }
        }
    }

    private func saveListing(_ imageURL: String?, _ videoURL: String?) {
        var data: [String: Any] = [
            "title": title,
            "price": price,
            "selectedCondition": selectedCondition,
            "description": description,
            "location": hideAddress ? "" : location,
            "city": city,
            "province": selectedProvince,
            "timestamp": Timestamp(date: Date())
        ]
        if let imageURL { data["imageUrl"] = imageURL }
        if let videoURL { data["videoUrl"]  = videoURL }

        FirestoreService.shared.addListing(data: data) { result in
            isPublishing = false
            switch result {
            case .success:
                selectedTab = .home
                resetForm()
            case .failure(let error):
                showError("Failed to add listing: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Helpers --------------------------------------------------------
    private func validateForm() -> String? {
        if title.isEmpty { return "Please enter a title" }
        if price.isEmpty { return "Please enter a price" }
        if selectedProvince == "Province" { return "Please select a province" }
        if city.isEmpty { return "Please enter a city" }
        if selectedImage == nil && selectedVideoURL == nil {
            return "Please add at least one photo or video"
        }
        return nil
    }

    private func showError(_ msg: String) {
        alertMessage = msg
        showAlert = true
        isPublishing = false
        print("Error:", msg)
    }
}
