From: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH v3.6 17/19] mwifiex: slight optimization of addr compare
Date: Tue, 7 Jan 2014 19:04:15 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430F534B5550@SC-VEXCH1.marvell.com>
References: <52CCBDDC.1050503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52CCBDDC.1050503-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

SGkgRGluZywNCg0KPiAtCWlmIChtZW1jbXAocHJpdi0+Y3Vycl9ic3NfcGFyYW1zLmJzc19kZXNj
cmlwdG9yLm1hY19hZGRyZXNzLA0KPiAtCQkgICBpYnNzX2NvYWxfcmVzcC0+YnNzaWQsIEVUSF9B
TEVOKSkgew0KPiArCWlmICghZXRoZXJfYWRkcl9lcXVhbChwcml2LT5jdXJyX2Jzc19wYXJhbXMu
YnNzX2Rlc2NyaXB0b3IubWFjX2FkZHJlc3MsIGlic3NfY29hbF9yZXNwLT5ic3NpZCkpDQoNClN0
aWxsIHdyb25nLi4uIDspDQoNCkhhdmUgeW91IGFjdHVhbGx5IHJ1biB0aGUgY2hlY2twYXRjaC5w
bCBzY3JpcHQ/DQoNCkJ5IHRoZSB3YXksIHlvdXIgc3ViamVjdCBwcmVmaXggIlBBVENIIHYzLjYi
IGlzIGNvbmZ1c2luZy4gSXQgb3VnaHQgdG8gYmUgIlBBVENIIHY2IiwgSSBndWVzcy4NCg0KVGhh
bmtzLA0KQmluZw0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
