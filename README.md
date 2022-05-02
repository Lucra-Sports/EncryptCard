# EncryptCard

[![Build and Test][badge.svg]][build-and-test.yml]

## Encrypt Credit/Debit Card
- Provide end-to-end encryption from user's device to payment gateway.
- Allows storing credit card information by merchants.

Replacement for card encryption by [PGMobileSDK.a][PGMobileSDK.a] - closed source compiled library, not updated since 2019.

## Advantages:
- enables Bitcode optimization for iOS app
- works on M1 iOS Simulator
- open source
- unit tests
- acceptance tests for decryption, see: https://github.com/Lucra-Sports/EncryptCardTests
- enables storing certificate in a standard format
- can be recompiled for future optimizations

[PGMobileSDK.a]: https://github.com/strues/react-native-nmi-bridge/tree/af6afde829f93c75959a221cb94331bc0875f83b/ios/Payment%20Gateway%20SDK
[badge.svg]: https://github.com/Lucra-Sports/EncryptCard/actions/workflows/build-and-test.yml/badge.svg
[build-and-test.yml]: https://github.com/Lucra-Sports/EncryptCard/actions/workflows/build-and-test.yml
