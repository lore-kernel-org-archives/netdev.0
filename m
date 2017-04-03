From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 2/5] qed: Fix TM block ILT allocation
Date: Mon, 3 Apr 2017 13:58:19 +0000
Message-ID: <BL2PR07MB23065BDE84DBA9DC5D2B8FBD8D080@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
 <1491211273-10910-3-git-send-email-Yuval.Mintz@cavium.com>
 <7b179126-2a66-8696-98f9-3f3dca7a6d9e@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0046.outbound.protection.outlook.com ([104.47.32.46]:62619
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752900AbdDCN6W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 09:58:22 -0400
In-Reply-To: <7b179126-2a66-8696-98f9-3f3dca7a6d9e@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICsJLyogVGltZXJzIGlzIGEgc3BlY2lhbCBjYXNlIC0+IHdlIGRvbid0IGNvdW50IGhvdyBt
YW55IGNpZHMgcmVxdWlyZQ0KPiANCj4gICAgIFMvaXMvYXJlLy4gQ0lEcz8NCg0KV2hhdCdzIGlt
cGxpY2l0bHkgbWVhbnQgaGVyZSBpcyB0aGUgJ1RpbWVyW3NdIEhXIGJsb2NrJy4NCkkgdW5kZXJz
dGFuZCBpdCBjcmVhdGVzIGFuIG9kZCBsb29raW5nIEVuZ2xpc2ggc2VudGVuY2UsIHRob3VnaC4N
Cg0KQXNzdW1pbmcgdGhlcmUnbGwgYmUgYSBWMiBmb3IgdGhpcyB3ZSdkIHJldmlzZSB0aGUgY29t
bWVudDsNCk90aGVyd2lzZSB3ZSdkIGRvIGl0IGluIHNvbWUgZnV0dXJlIGNsZWFudXAgcGF0Y2gu
DQoNCg==
