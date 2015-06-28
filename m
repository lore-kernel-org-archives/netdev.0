From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow_dissector: Pre-initialize ip_proto in
 __skb_flow_dissect()
Date: Sun, 28 Jun 2015 16:54:20 -0700 (PDT)
Message-ID: <20150628.165420.750527732113926573.davem@davemloft.net>
References: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: tom@herbertland.com, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMjUgSnVuIDIwMTUgMTU6MTA6MzIgKzAyMDANCg0KPiBuZXQvY29yZS9mbG93X2Rpc3NlY3Rv
ci5jOiBJbiBmdW5jdGlvbiChX19za2JfZmxvd19kaXNzZWN0ojoNCj4gbmV0L2NvcmUvZmxvd19k
aXNzZWN0b3IuYzoxMzI6IHdhcm5pbmc6IKFpcF9wcm90b6IgbWF5IGJlIHVzZWQgdW5pbml0aWFs
aXplZCBpbiB0aGlzIGZ1bmN0aW9uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0ZXJo
b2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KDQpBcHBsaWVkLCB0aGFua3MuDQo=
