From: "Xue, Ying" <Ying.Xue@windriver.com>
Subject: RE: [PATCH] tipc: unlock in error path
Date: Thu, 18 Feb 2016 13:12:46 +0000
Message-ID: <25A14D9CFAB7B34FB9440F90AFD35233DD0AF10E@ALA-MBB.corp.ad.wrs.com>
References: <1455727655-32106-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Cc: "taesoo@gatech.edu" <taesoo@gatech.edu>,
	"yeongjin.jang@gatech.edu" <yeongjin.jang@gatech.edu>,
	"insu@gatech.edu" <insu@gatech.edu>,
	"changwoo@gatech.edu" <changwoo@gatech.edu>
To: Insu Yun <wuninsu@gmail.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455727655-32106-1-git-send-email-wuninsu@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QWNrZWQtYnk6IFlpbmcgWHVlICA8eWluZy54dWVAd2luZHJpdmVyLmNvbT4NCg0KLS0tLS1Pcmln
aW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEluc3UgWXVuIFttYWlsdG86d3VuaW5zdUBnbWFpbC5j
b21dIA0KU2VudDogMjAxNsTqMtTCMTjI1SAwOjQ4DQpUbzogam9uLm1hbG95QGVyaWNzc29uLmNv
bTsgWHVlLCBZaW5nOyBkYXZlbUBkYXZlbWxvZnQubmV0OyBuZXRkZXZAdmdlci5rZXJuZWwub3Jn
OyB0aXBjLWRpc2N1c3Npb25AbGlzdHMuc291cmNlZm9yZ2UubmV0OyBsaW51eC1rZXJuZWxAdmdl
ci5rZXJuZWwub3JnDQpDYzogdGFlc29vQGdhdGVjaC5lZHU7IHllb25namluLmphbmdAZ2F0ZWNo
LmVkdTsgaW5zdUBnYXRlY2guZWR1OyBjaGFuZ3dvb0BnYXRlY2guZWR1OyBJbnN1IFl1bg0KU3Vi
amVjdDogW1BBVENIXSB0aXBjOiB1bmxvY2sgaW4gZXJyb3IgcGF0aA0KDQp0aXBjX2JjYXN0X3Vu
bG9jayBuZWVkIHRvIGJlIHVubG9ja2VkIGluIGVycm9yIHBhdGguDQoNClNpZ25lZC1vZmYtYnk6
IEluc3UgWXVuIDx3dW5pbnN1QGdtYWlsLmNvbT4NCi0tLQ0KIG5ldC90aXBjL2xpbmsuYyB8IDQg
KysrLQ0KIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCg0K
ZGlmZiAtLWdpdCBhL25ldC90aXBjL2xpbmsuYyBiL25ldC90aXBjL2xpbmsuYyBpbmRleCAwYzI5
NDRmLi4zNDdjZGM5IDEwMDY0NA0KLS0tIGEvbmV0L3RpcGMvbGluay5jDQorKysgYi9uZXQvdGlw
Yy9saW5rLmMNCkBAIC0xOTczLDggKzE5NzMsMTAgQEAgaW50IHRpcGNfbmxfYWRkX2JjX2xpbmso
c3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgdGlwY19ubF9tc2cgKm1zZykNCiANCiAJaGRyID0gZ2Vu
bG1zZ19wdXQobXNnLT5za2IsIG1zZy0+cG9ydGlkLCBtc2ctPnNlcSwgJnRpcGNfZ2VubF9mYW1p
bHksDQogCQkJICBOTE1fRl9NVUxUSSwgVElQQ19OTF9MSU5LX0dFVCk7DQotCWlmICghaGRyKQ0K
KwlpZiAoIWhkcikgew0KKwkJdGlwY19iY2FzdF91bmxvY2sobmV0KTsNCiAJCXJldHVybiAtRU1T
R1NJWkU7DQorCX0NCiANCiAJYXR0cnMgPSBubGFfbmVzdF9zdGFydChtc2ctPnNrYiwgVElQQ19O
TEFfTElOSyk7DQogCWlmICghYXR0cnMpDQotLQ0KMS45LjENCg0K
