import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/src/eval/shared/stdlib/core/num.dart';
import 'package:test/test.dart';

void main() {
  group('Expression tests', () {
    late Compiler compiler;

    setUp(() {
      compiler = Compiler();
    });

    test('"is" expression', () {
      final runtime = compiler.compileWriteAndLoad({
        'eval_test': {
          'main.dart': '''
            void main() {
              print(1 is int);
              print(2 is! String);
              print([] is List);
              print(RegExp(r'.*') is RegExp);
              print(RegExp(r'.*') is! RegExp);
              print(RegExp(r'.*') is String);
              print(Y() is X);
              print(X() is Y);
            }

            class X {
              X();
            }

            class Y extends X {
              Y();
            }
          '''
        }
      });

      expect(() {
        runtime.executeLib('package:eval_test/main.dart', 'main');
      }, prints('true\ntrue\ntrue\ntrue\nfalse\nfalse\ntrue\nfalse\n'));
    });

    test('Is num', () {
      final runtime = compiler.compileWriteAndLoad({
        'eval_test': {
          'main.dart': '''
            num main () {
              var myfunc = ([dynamic a, dynamic b = 4]) {
                if(a is num && b is num){
                  return a + b;
                }
                return 0;
              };
              return myfunc(2);
            }
          '''
        }
      });

      expect(runtime.executeLib('package:eval_test/main.dart', 'main'), $int(6));
    });

    test('Null coalescing operator', () {
      final runtime = compiler.compileWriteAndLoad({
        'eval_test': {
          'main.dart': '''
            void main() {
              print(null ?? 1);
              print(2 ?? 1);
            }
          '''
        }
      });

      expect(() {
        runtime.executeLib('package:eval_test/main.dart', 'main');
      }, prints('1\n2\n'));
    });

    test("Not expression", () {
      final runtime = compiler.compileWriteAndLoad({
        'eval_test': {
          'main.dart': '''
            void main() {
              print(!true);
              print(!false);
            }
          '''
        }
      });

      expect(() {
        runtime.executeLib('package:eval_test/main.dart', 'main');
      }, prints('false\ntrue\n'));
    });

    test('Bitwise int operators', () {
      final runtime = compiler.compileWriteAndLoad({
        'eval_test': {
          'main.dart': '''
            void main() {
              print(1 & 2);
              print(1 | 2);
              print(1 << 2);
              print(1 >> 2);
              print(1 ^ 2);
            }
          '''
        }
      });

      expect(() {
        runtime.executeLib('package:eval_test/main.dart', 'main');
      }, prints('0\n3\n4\n0\n3\n'));
    });

    test('Conditional expression', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            int main () {
              return fun(3);
            }
            
            int fun(int a) {
              return a > 2 ? 1 : 2;
            }
           '''
        }
      });

      expect(runtime.executeLib('package:example/main.dart', 'main'), 1);
    });

    test('Simple cascade', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              var x = X();
              x..a = 1..b = 2;
              print(x.a);
              print(x.b);
            }
            
            class X {
              int a = 0;
              int b = 0;
            }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, prints('1\n2\n'));
    });

    test('Cascade with method call', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              var x = X();
              x..a = 1..b = 2..printValues();
            }
            
            class X {
              int a = 0;
              int b = 0;
              void printValues() {
                print(a);
                print(b);
              }
            }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, prints('1\n2\n'));
    });

    test('Null coalescing assignment', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              var x;
              x ??= 1;
              print(x);
              x ??= 2;
              print(x);
            }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, prints('1\n1\n'));
    });

    test('Class cast', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              dynamic x = X();
              print((x as X).getName());
            }
            
            class X {
              String getName() => 'X class';
            }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, prints('X class\n'));
    });

    test('Num cast', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              num x = 1;
              print((x as int) + 1);
            }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, prints('2\n'));
    });

    test('Failing cast', () {
      final runtime = compiler.compileWriteAndLoad({
        'example': {
          'main.dart': '''
            void main() {
              dynamic x = X();
              print((x as Y).getName());
            }
            
            class X { String getName() => 'X class'; }
            class Y { String getName() => 'Y class'; }
           '''
        }
      });

      expect(() {
        runtime.executeLib('package:example/main.dart', 'main');
      }, throwsA(anything));
    });
  });
}
