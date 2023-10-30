//
//  ExploreViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class ExploreViewController: UIViewController {

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()

        bar.placeholder = "Search..."
        bar.layer.cornerRadius = 8
        bar.layer.masksToBounds = true
        return bar
    }()

    private var sections = [ExploreSection]()

    private var collectionView: UICollectionView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()

        view.backgroundColor = .systemBackground
        setUpSearchBar()
        setUpCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView?.frame = view.bounds
    }

    func setUpSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }

    func configureModels() {
        var cells = [ExploreCell]()
        for _ in 0...100 {
            let cell = ExploreCell.banner(
                viewModel: ExploreBannerViewModel(
                    image: nil,
                    title: "Foo",
                    handler: {

                    }
                )
            )
            cells.append(cell)
        }

        var posts = [ExploreCell]()
        for _ in 0...40 {
            posts.append(
                ExploreCell.post(viewModel: ExplorePostViewModel(
                    thumbailImage: nil,
                    caption: "",
                    handler: {

                    }))
            )
        }

        sections = [
            ExploreSection(
                type: .banners,
                cells: cells
            ),
            ExploreSection(
                type: .trendingPosts,
                cells: posts
            ),
            ExploreSection(
                type: .users,
                cells: [
                    .user(viewModel: ExploreUserViewModel(
                        profilePictureURL: nil,
                        username: "",
                        followerCount: 0,
                        handler: {

                        })),
                    .user(viewModel: ExploreUserViewModel(
                        profilePictureURL: nil,
                        username: "",
                        followerCount: 0,
                        handler: {

                        })),
                    .user(viewModel: ExploreUserViewModel(
                        profilePictureURL: nil,
                        username: "",
                        followerCount: 0,
                        handler: {

                        })),
                    .user(viewModel: ExploreUserViewModel(
                        profilePictureURL: nil,
                        username: "",
                        followerCount: 0,
                        handler: {

                        })),
                ]
            ),
            ExploreSection(
                type: .trendingHashtags,
                cells: [
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: nil,
                        text: "#foryou",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: nil,
                        text: "#foryou",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: nil,
                        text: "#foryou",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: nil,
                        text: "#foryou",
                        count: 1,
                        handler: {

                        })),
                ]
            ),
            ExploreSection(
                type: .recommended,
                cells: [
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                ]
            ),
            ExploreSection(
                type: .popular,
                cells: [
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                ]
            ),
            ExploreSection(
                type: .new,
                cells: [
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                    .post(viewModel: ExplorePostViewModel(
                        thumbailImage: nil,
                        caption: "",
                        handler: {

                        })),
                ]
            ),
        ]
    }

    func setUpCollectionView() {
        let layout = UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
            return self.layout(for: section)
        }

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        self.collectionView = collectionView
    }

    func layout(for section: Int) -> NSCollectionLayoutSection {
        let sectionType = sections[section].type

        switch sectionType {

        case .banners:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(200)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .groupPaging

            return sectionLayout
        case .users:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .groupPaging

            return sectionLayout
        case .trendingHashtags:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(60)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: verticalGroup)

            return sectionLayout
        case .popular:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(110),
                    heightDimension: .absolute(200)
                ),
                subitems: [item])

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous

            return sectionLayout
        case .new, .trendingPosts, .recommended:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(100),
                    heightDimension: .absolute(240)
                ),
                subitem: item,
                count: 2
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(110),
                    heightDimension: .absolute(240)
                ),
                subitems: [verticalGroup])

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous

            return sectionLayout
        }
    }

}

// MARK: - UISearchBar delegate methods

extension ExploreViewController: UISearchBarDelegate {

}

// MARK: - UICollectionView delegate and datasource methods

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model: ExploreCell = sections[indexPath.section].cells[indexPath.row]

        switch model {

        case .banner(let viewModel):
            break
        case .post(let viewModel):
            break
        case .hashtag(let viewModel):
            break
        case .user(let viewModel):
            break
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        cell.backgroundColor = .red
        return cell
    }

}
