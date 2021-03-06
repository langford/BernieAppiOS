import Foundation

class NewsFeedVideoTableViewCell: UITableViewCell {
    let titleLabel = UILabel.newAutoLayoutView()
    let descriptionLabel = UILabel.newAutoLayoutView()
    let thumbnailImageView = UIImageView.newAutoLayoutView()
    let overlayView = UIView.newAutoLayoutView()
    let playIconImageView = UIImageView.newAutoLayoutView()
    var topSpaceConstraint: NSLayoutConstraint!

    private let containerView = UIView.newAutoLayoutView()
    private let defaultMargin: CGFloat = 15

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .None

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(overlayView)
        containerView.addSubview(playIconImageView)
        containerView.clipsToBounds = true

        backgroundColor = UIColor.clearColor()

        containerView.backgroundColor = UIColor.whiteColor()

        accessoryType = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false

        titleLabel.numberOfLines = 3
        descriptionLabel.numberOfLines = 3

        playIconImageView.image = UIImage(named: "playIcon")

        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .ScaleAspectFill

        setupConstraints()
    }

    private func setupConstraints() {
        topSpaceConstraint = containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 9)
        containerView.autoPinEdgeToSuperviewEdge(.Left)
        containerView.autoPinEdgeToSuperviewEdge(.Right)
        containerView.autoPinEdgeToSuperviewEdge(.Bottom)

        let screenBounds = UIScreen.mainScreen().bounds

        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Top)
        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Right)
        thumbnailImageView.autoPinEdgeToSuperviewEdge(.Left)
        thumbnailImageView.autoSetDimension(.Height, toSize: screenBounds.width / 1.7777)

        overlayView.autoPinEdge(.Top, toEdge: .Top, ofView: thumbnailImageView)
        overlayView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: thumbnailImageView)
        overlayView.autoPinEdge(.Left, toEdge: .Left, ofView: thumbnailImageView)
        overlayView.autoPinEdge(.Right, toEdge: .Right, ofView: thumbnailImageView)

        playIconImageView.autoSetDimension(.Height, toSize: 75)
        playIconImageView.autoSetDimension(.Width, toSize: 75)
        playIconImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: thumbnailImageView)
        playIconImageView.autoAlignAxis(.Vertical, toSameAxisOfView: thumbnailImageView)

        titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: thumbnailImageView, withOffset: 16)
        titleLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultMargin)
        titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)

        descriptionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 5)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: defaultMargin)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: defaultMargin)
        descriptionLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 50)
    }
}
