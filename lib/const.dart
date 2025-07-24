import 'package:flutter/services.dart';

const MethodChannel channel = const MethodChannel('ft_mobile_agent_flutter');

const methodConfig = "ftConfig";
const methodFlushSyncData = "ftFlushSyncData";

const methodBindUser = "ftBindUser";
const methodUnbindUser = "ftUnBindUser";
const methodEnableAccessAndroidID = "ftEnableAccessAndroidID";
const methodTrackEventFromExtension = "ftTrackEventFromExtension";
const methodAppendGlobalContext = "ftAppendGlobalContext";
const methodAppendRUMGlobalContext = "ftAppendRUMGlobalContext";
const methodAppendLogGlobalContext = "ftAppendLogGlobalContext";
const methodClearAllData = "ftClearAllData";

const methodLogConfig = "ftLogConfig";
const methodLogging = "ftLogging";

const methodRumConfig = "ftRumConfig";
const methodRumStartAction = "ftRumStartAction";
const methodRumAddAction = "ftRumAddAction";
const methodRumStartView = "ftRumStartView";
const methodRumCreateView = "ftRumCreateView";
const methodRumStopView = "ftRumStopView";
const methodRumAddError = "ftRumAddError";
const methodRumStartResource = "ftRumStartResource";
const methodRumStopResource = "ftRumStopResource";
const methodRumAddResource = "ftRumAddResource";

const methodTraceConfig = "ftTraceConfig";
const methodTrace = "ftTrace";
const methodGetTraceGetHeader = "ftTraceGetHeader";
const methodSetInnerLogHandler = "ftSetInnerLogHandler";
const methodInvokeInnerLog = "ftInvokeInnerLog";
