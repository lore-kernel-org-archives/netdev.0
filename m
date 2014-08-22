From: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Subject: RE: [PATCH] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Fri, 22 Aug 2014 11:40:15 +0000
Message-ID: <FDC088D3B5555644AE135ED28A7ABDE94DF3165A@EU-MBX-02.mgc.mentorg.com>
References: <1407827133-29493-1-git-send-email-sanjeev_sharma@mentor.com>
	 <FDC088D3B5555644AE135ED28A7ABDE94DF2FDC2@EU-MBX-02.mgc.mentorg.com>
	 (sfid-20140819_083957_833442_DEE44B0A)
 <1408707084.4349.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dsd@gentoo.org" <dsd@gentoo.org>,
	"kune@deine-taler.de" <kune@deine-taler.de>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408707084.4349.0.camel@jlt4.sipsolutions.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WWVzLCBpdCBjb21waWxpbmcgc3VjY2Vzc2Z1bGx5Lg0KDQoNCi0tLS0tT3JpZ2luYWwgTWVzc2Fn
ZS0tLS0tDQpGcm9tOiBKb2hhbm5lcyBCZXJnIFttYWlsdG86am9oYW5uZXNAc2lwc29sdXRpb25z
Lm5ldF0gDQpTZW50OiBGcmlkYXksIEF1Z3VzdCAyMiwgMjAxNCA1OjAxIFBNDQpUbzogU2hhcm1h
LCBTYW5qZWV2DQpDYzogZHNkQGdlbnRvby5vcmc7IGt1bmVAZGVpbmUtdGFsZXIuZGU7IGxpbnZp
bGxlQHR1eGRyaXZlci5jb207IGxpbnV4LXdpcmVsZXNzQHZnZXIua2VybmVsLm9yZzsgbmV0ZGV2
QHZnZXIua2VybmVsLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KU3ViamVjdDog
UmU6IFtQQVRDSF0gemQxMjExcnc6IHJlcGxhY2UgWkRfQVNTRVJUIHdpdGggbG9ja2RlcF9hc3Nl
cnRfaGVsZCgpDQoNCk9uIFR1ZSwgMjAxNC0wOC0xOSBhdCAwNjozOSArMDAwMCwgU2hhcm1hLCBT
YW5qZWV2IHdyb3RlOg0KPiBQaW5nIGZvciByZXZpZXcgdGhlIHBhdGNoLg0KDQpNYWtlIHN1cmUg
aXQgY29tcGlsZXMgLi4uDQoNCg0KDQo=
