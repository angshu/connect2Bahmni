import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/models/omrs_concept.dart';
import '../domain/models/omrs_encounter_type.dart';
import '../services/concept_dictionary.dart';
import '../domain/models/omrs_visit_type.dart';
import '../services/encounters.dart';

class MetaProvider with ChangeNotifier {
  OmrsConcept? _conditionCertainty;
  OmrsConcept? _diagnosisOrder;
  OmrsConcept? _consultNoteConcept;
  List<OmrsVisitType>? _visitTypes;
  List<OmrsEncounterType>? _encTypes;

  OmrsConcept? get conditionCertainty => _conditionCertainty;
  OmrsConcept? get diagnosisOrder => _diagnosisOrder;
  OmrsConcept? get consultNoteConcept => _consultNoteConcept;
  List<OmrsVisitType>? get visitTypes => _visitTypes;
  List<OmrsEncounterType>? get encTypes => _encTypes;

  List<OmrsVisitType>? get allowedVisitTypes {
    if (_visitTypes == null) return [];
    var allowedList = dotenv.get('app.allowedVisitTypes', fallback: '')
        .split(',')
        .map((e) => e.trim().toLowerCase()).toList();
    return _visitTypes!.where((e) => allowedList.contains(e.display?.toLowerCase())).toList();
  }

  List<OmrsEncounterType>? get allowedEncTypes {
    if (_encTypes == null) return [];
    var allowedList = dotenv.get('app.allowedEncTypes', fallback: '')
        .split(',')
        .map((e) => e.trim().toLowerCase()).toList();
    return _encTypes!.where((e) => allowedList.contains(e.display?.toLowerCase())).toList();
  }

  void initialize() {
    ConceptDictionary().fetchDiagnosisCertainty().then((value) {
      _conditionCertainty = value;
      notifyListeners();
    });
    ConceptDictionary().fetchDiagnosisOrder().then((value) {
      _diagnosisOrder = value;
      notifyListeners();
    });
    Encounters().visitTypes().then((value) {
      _visitTypes = value;
      notifyListeners();
    }).catchError((e) => _logError(e));

    Encounters().encTypes().then((value) {
      _encTypes = value;
      notifyListeners();
    }).catchError((e) => _logError(e));

    var consultConceptUuid = dotenv.get('app.conceptConsultationNotes', fallback: '');
    if (consultConceptUuid.isNotEmpty) {
      ConceptDictionary().fetchConceptByUuid(consultConceptUuid).then((value) {
        _consultNoteConcept = value;
        notifyListeners();
      }).catchError((e) => _logError(e));
    }
  }

  _logError(e) {
    debugPrint(e);
  }

}