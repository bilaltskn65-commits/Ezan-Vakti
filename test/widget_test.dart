import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_vakti/models/hafiz_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HafizList model test', () {
    expect(HafizList.reciters.length, 10);
    expect(HafizList.reciters.first.nameTr, 'Mişari Raşid el-Afasi');
  });

  test('SharedPreferences mock test', () async {
    SharedPreferences.setMockInitialValues({'saved_city': 'İstanbul'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('saved_city'), 'İstanbul');
  });
}
