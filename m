From: Patrick Ruddy <pruddy@Brocade.com>
Subject: Re: [net-next PATCH] net: netlink messages for HW addr programming
Date: Mon, 19 Sep 2016 14:46:19 +0000
Message-ID: <1474296378.31262.59.camel@brocade.com>
References: <1473958082-30982-1-git-send-email-pruddy@brocade.com>
         <57DEA9E2.3000703@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Luca Boccassi <lboccass@Brocade.com>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        Sven-Thorsten Dietrich <sven@brocade.com>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53845 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750794AbcISOvD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:51:03 -0400
Received: from pps.filterd (m0048193.ppops.net [127.0.0.1])
        by mx0a-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8JEo2Se031617
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 07:51:02 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0a-000f0801.pphosted.com with ESMTP id 25ht86cjp6-5
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 07:51:02 -0700
In-Reply-To: <57DEA9E2.3000703@cumulusnetworks.com>
Content-Language: en-US
Content-ID: <07E111F06B50CA48AF25F41ED1325E38@brocade.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gU3VuLCAyMDE2LTA5LTE4IGF0IDA3OjUxIC0wNzAwLCBSb29wYSBQcmFiaHUgd3JvdGU6DQo+
IE9uIDkvMTUvMTYsIDk6NDggQU0sIFBhdHJpY2sgUnVkZHkgd3JvdGU6DQo+ID4gQWRkIFJUTV9O
RVdBRERSIGFuZCBSVE1fREVMQUREUiBuZXRsaW5rIG1lc3NhZ2VzIHdpdGggZmFtaWx5DQo+ID4g
QUZfVU5TUEVDIHRvIGluZGljYXRlIGludGVyZXN0IGluIHNwZWNpZmljIHVuaWNhc3QgYW5kIG11
bHRpY2FzdA0KPiA+IGhhcmR3YXJlIGFkZHJlc3Nlcy4gVGhlc2UgbWVzc2FnZXMgYXJlIHNlbnQg
d2hlbiBhZGRyZXNzZXMgYXJlDQo+ID4gYWRkZWQgb3IgZGVsZXRlZCBmcm9tIHRoZSBhcHByb3By
aWF0ZSBpbnRlcmZhY2UgZHJpdmVyLg0KPiA+IEFkZGVkIEFGX1VOU1BFQyBHRVRBRERSIGZ1bmN0
aW9uIHRvIGFsbG93IHRoZSBuZXRsaW5rIG5vdGlmaWNhdGlvbnMNCj4gPiB0byBiZSByZXBsYXll
ZCB0byBhdm9pZCBsb3NzIG9mIHN0YXRlIGR1ZSB0byBhcHBsaWNhdGlvbiBzdGFydA0KPiA+IG9y
ZGVyaW5nIG9yIHJlc3RhcnQuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBQYXRyaWNrIFJ1ZGR5
IDxwcnVkZHlAYnJvY2FkZS5jb20+DQo+ID4gLS0tDQo+IA0KPiBSVE1fTkVXQUREUiBhbmQgUlRN
X0RFTEFERFIgYXJlIG5vdCB1c2VkIHRvIGFkZCB0aGVzZSBlbnRyaWVzIHRvIHRoZSBrZXJuZWwu
DQo+IHNvLCBpdCBzZWVtcyBhIGJpdCB3cm9uZyB0byB1c2UgUlRNX05FV0FERFIgYW5kIFJUTV9E
RUxBRERSIHRvIG5vdGlmeSB0aGVtIHRvDQo+IHVzZXJzcGFjZSBhbmQgYWxzbyB0byByZXF1ZXN0
IGEgc3BlY2lhbCBkdW1wIG9mIHRoZXNlIGFkZHJlc3Nlcy4NCj4gDQo+IFRoaXMgY291bGQganVz
dCBiZSBhIG5ldyBuZXN0ZWQgbmV0bGluayBhdHRyaWJ1dGUgaW4gdGhlIGV4aXN0aW5nIGxpbmsg
ZHVtcCA/DQoNCkhpIFJvb3BhDQoNClRoYW5rcyBmb3IgdGhlIHJldmlldy4gSSBkaWQgaW5pdGlh
bGx5IGNvZGUgdGhpcyB1c2luZyBORVcvREVML0dFVF9MSU5LDQptZXNzYWdlcyBidXQgd2FzIGFz
a2VkIHRvIGNoYW5nZSB0byB0byBBRERSIG1lc3NhZ2VzIGJ5IFN0ZXBoZW4NCkhlbW1pbmdlciAo
Y2MnZCkuIA0KDQpIb3dldmVyIEkgYWdyZWUgdGhhdCB0aGVzZSBhZGRyZXNzZXMgZmFsbCBiZXR3
ZWVuIHRoZSBMSU5LIGFuZCBBRERSDQphcmVhcyBzbyBJJ20gaGFwcHkgdG8gY2hhbmdlIHRoaXMg
aWYgd2UgY2FuIHJlYWNoIHNvbWUgY29uc2Vuc3VzIG9uIHRoZQ0KZm9ybWF0Lg0KDQp0aGFua3MN
Cg0KLXByDQo=
