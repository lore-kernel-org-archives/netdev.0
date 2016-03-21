From: <Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Subject: RE: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 14:41:03 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404CBFC0@CHN-SV-EXMX02.mchp-main.com>
References: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
 <1458549361.2299.1.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <oneukum-IBi9RG/b67k@public.gmane.org>, <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458549361.2299.1.camel-IBi9RG/b67k@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBPbGl2ZXIgTmV1a3VtIFttYWls
dG86b25ldWt1bUBzdXNlLmNvbV0NCj4gU2VudDogTW9uZGF5LCBNYXJjaCAyMSwgMjAxNiA0OjM2
IEFNDQo+IFRvOiBHZWVydCBVeXR0ZXJob2V2ZW4NCj4gQ2M6IFdvb2p1bmcgSHVoIC0gQzIxNjk5
OyBVTkdMaW51eERyaXZlcjsgRGF2aWQgUy4gTWlsbGVyOyBHdWVudGVyIFJvZWNrOw0KPiBSYWZh
ZWwgSi4gV3lzb2NraTsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgbGludXgtdXNiQHZnZXIua2Vy
bmVsLm9yZzsNCj4gbGludXgtcG1Admdlci5rZXJuZWwub3JnOyBsaW51eC1rZXJuZWxAdmdlci5r
ZXJuZWwub3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0hdIGxhbjc4eHg6IFByb3RlY3QgcnVudGlt
ZV9hdXRvIGNoZWNrIGJ5ICNpZmRlZg0KPiBDT05GSUdfUE0NCg0KVGhhbmtzIGZvciBhbGwgY29t
bWVudHMuDQpXaWxsIGxvb2sgaW50byBpdCBhbmQgc3VibWl0IG5ldyBwYXRjaC4NCg0KLSBXb29q
dW5nDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
