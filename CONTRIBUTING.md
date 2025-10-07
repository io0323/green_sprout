# Contributing to Tea Garden AI

Thank you for your interest in contributing to Tea Garden AI! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Git

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/green_sprout.git
   cd green_sprout
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/io0323/green_sprout.git
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

```
lib/
├── core/                    # Shared functionality
│   ├── constants/          # App constants
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error handling
│   ├── utils/              # Utility functions
│   └── usecases/           # Base use case classes
├── features/               # Feature modules
│   ├── tea_analysis/       # Tea analysis feature
│   ├── camera/             # Camera feature
│   └── logs/               # Logs feature
└── main.dart               # App entry point
```

### Layer Responsibilities

- **Presentation Layer**: UI, state management (BLoC)
- **Domain Layer**: Business logic, entities, use cases, repository interfaces
- **Data Layer**: Repository implementations, data sources, data models
- **Core Layer**: Shared utilities, error handling, dependency injection

## 📝 Development Guidelines

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check code quality
- Follow the existing code patterns and conventions

### Naming Conventions

- **Files**: snake_case (e.g., `tea_analysis_result.dart`)
- **Classes**: PascalCase (e.g., `TeaAnalysisResult`)
- **Variables/Functions**: camelCase (e.g., `getAnalysisResult`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(tea-analysis): add confidence threshold validation
fix(camera): resolve image capture permission issue
docs(readme): update installation instructions
```

### Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, well-documented code
   - Add tests if applicable
   - Update documentation if needed

3. **Test your changes**
   ```bash
   flutter analyze
   flutter test
   flutter run
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to GitHub and create a PR
   - Fill out the PR template
   - Request review from maintainers

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for user flows
- Aim for high test coverage

## 📱 Platform-Specific Guidelines

### Android

- Minimum SDK: 26 (required for TFLite Flutter)
- Test on different Android versions
- Handle permissions properly

### iOS

- Minimum iOS: 11.0
- Test on different iOS versions
- Handle camera permissions

### Web

- Test on different browsers
- Ensure responsive design
- Handle camera access limitations

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment details**
   - Flutter version
   - Dart version
   - Platform (Android/iOS/Web)
   - Device/emulator details

2. **Steps to reproduce**
   - Clear, numbered steps
   - Expected vs actual behavior

3. **Additional context**
   - Screenshots/videos if applicable
   - Logs or error messages
   - Related issues

## 💡 Feature Requests

When suggesting features:

1. **Check existing issues** first
2. **Describe the problem** you're trying to solve
3. **Propose a solution** with details
4. **Consider implementation** complexity
5. **Think about** user experience

## 📚 Documentation

### Code Documentation

- Use Dart doc comments for public APIs
- Include examples in documentation
- Keep documentation up-to-date

### README Updates

- Update README when adding new features
- Include setup instructions for new dependencies
- Update platform requirements if needed

## 🔒 Security

- Don't commit sensitive information
- Use environment variables for API keys
- Follow security best practices
- Report security issues privately

## 📞 Getting Help

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Code Review**: All PRs require review before merging

## 🎯 Areas for Contribution

- **AI/ML**: Improve TFLite model integration
- **UI/UX**: Enhance user interface and experience
- **Performance**: Optimize app performance
- **Testing**: Add more comprehensive tests
- **Documentation**: Improve documentation
- **Platform Support**: Add support for new platforms
- **Features**: Add new functionality

## 📋 Pull Request Template

When creating a PR, please include:

### Description
Brief description of changes

### Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

### Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to Tea Garden AI! 🌱
