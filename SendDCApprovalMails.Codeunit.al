codeunit 64633 "Send DC Approval Mails"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        SendTheMails(Rec);
    end;

    local procedure SendTheMails(var JobQueueEntry: Record "Job Queue Entry");
    var
        BaseCalendar: Record "Base Calendar";
        CalendarMgmt: codeunit "Calendar Management";
        CDCDocumentCaptureSetup: Record "CDC Document Capture Setup";
        CDCPurchApprovalEMail: Codeunit "CDC Purch. Approval E-Mail";
        Description: text[50];
        Nonworking: Boolean;
    begin
        if JobQueueEntry."Parameter String" = '' then
            Error(DefineBaseCalendar);
        if not BaseCalendar.get(JobQueueEntry."Parameter String") then
            Error(StrSubstNo(BaseCalendarNotFound, JobQueueEntry."Parameter String"));

        Nonworking := CalendarMgmt.CheckDateStatus(JobQueueEntry."Parameter String", WorkDate(), Description);
        if not Nonworking then begin
            CDCDocumentCaptureSetup.Get();

            Clear(CDCPurchApprovalEMail);
            CDCPurchApprovalEMail.SetAdditionalEmailText(
                CDCDocumentCaptureSetup.AddBR() +
                CDCDocumentCaptureSetup.ChangeLfIntoBR(CDCDocumentCaptureSetup."Additional Email Footer"));
            CDCPurchApprovalEMail.Run();
        end;
    end;

    var
        DefineBaseCalendar: Label 'Define a Base Calendar in the Parameter String';
        BaseCalendarNotFound: Label 'Base Calendar %1 not found';
        Text01: label 'Text 001';
}