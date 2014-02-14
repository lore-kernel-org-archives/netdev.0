From: "liujunliang_ljl" <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
Subject: Re: Re: [PATCH] Fix Default to 'y' for SR9800 Device Driver, settingto 'n'
Date: Fri, 14 Feb 2014 14:43:27 +0800
Message-ID: <201402141443245136452@163.com>
References: <1392265339-14841-1-git-send-email-liujunliang_ljl@163.com>,
 <20140213.183237.1108958546198981160.davem@davemloft.net>,
 <52FD6579.5070104@cogentembedded.com>,
 <20140213.184221.1712626655601756449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: base64
Cc: "thierry.reding" <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"horms" <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>, "joe" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"romieu" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
	"gregkh" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"netdev" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"sunhecheng" <sunhecheng-i49A8sVr+H5BDgjK7y7TUQ@public.gmane.org>
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"sergei.shtylyov" <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RGVhciBEYXZpZCA6DQoNCgkJCVRoYW5rcyBhbGwgdGhlIHNhbWUuDQoNCg0KMjAxNC0wMi0xNCAN
Cg0KDQoNCmxpdWp1bmxpYW5nX2xqbCANCg0KDQoNCreivP7Iy6O6IERhdmlkIE1pbGxlciANCrei
y83Ksbzko7ogMjAxNC0wMi0xNCAgMDc6NDI6MjQgDQrK1bz+yMujuiBzZXJnZWkuc2h0eWx5b3Yg
DQqzrcvNo7ogbGl1anVubGlhbmdfbGpsOyB0aGllcnJ5LnJlZGluZzsgaG9ybXM7IGpvZTsgcm9t
aWV1OyBncmVna2g7IG5ldGRldjsgbGludXgtdXNiOyBsaW51eC1rZXJuZWw7IHN1bmhlY2hlbmcg
DQrW98zio7ogUmU6IFtQQVRDSF0gRml4IERlZmF1bHQgdG8gJ3knIGZvciBTUjk4MDAgRGV2aWNl
IERyaXZlciwgc2V0dGluZ3RvICduJyANCiANCkZyb206IFNlcmdlaSBTaHR5bHlvdiA8c2VyZ2Vp
LnNodHlseW92QGNvZ2VudGVtYmVkZGVkLmNvbT4NCkRhdGU6IEZyaSwgMTQgRmViIDIwMTQgMDM6
Mzg6MTcgKzAzMDANCj4gSGVsbG8uDQo+IA0KPiBPbiAwMi8xNC8yMDE0IDAyOjMyIEFNLCBEYXZp
ZCBNaWxsZXIgd3JvdGU6DQo+IA0KPj4+IEZyb206IExpdSBKdW5saWFuZyA8bGl1anVubGlhbmdf
bGpsQDE2My5jb20+DQo+IA0KPj4+IFNpZ25lZC1vZmYtYnk6IExpdSBKdW5saWFuZyA8bGl1anVu
bGlhbmdfbGpsQDE2My5jb20+DQo+IA0KPj4gSSB0aGluayBpdCdzIG1vcmUgY2Fub25pY2FsIHRv
IHNwZWNpZnkgbm8gZGVmYXVsdCBhdCBhbGwuDQo+IA0KPiAgICBUaGF0J3Mgd2hhdCBoZSBkaWQs
IG5vPw0KSW5kZWVkLCBteSBiYWQsIHBhdGNoIGFwcGxpZWQsIHRoYW5rcyENCi4NCg==


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
