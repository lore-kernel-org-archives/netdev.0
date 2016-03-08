From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Tue, 8 Mar 2016 11:24:00 +0100
Message-ID: <56DEA840.1050305@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com>
 <56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
 <CAG374jBLD5YuBT=r3V98OqdUTXMepvQ_tLz4XMJdQMzzGYi22A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 =?UTF-8?B?SGVpa28=?= =?UTF-8?B?IFN0w7xibmVy?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Dinh Nguyen
 <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CAG374jBLD5YuBT=r3V98OqdUTXMepvQ_tLz4XMJdQMzzGYi22A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gMy84LzIwMTYgMTE6MDMgQU0sIEdhYnJpZWwgRmVybmFuZGV6IHdyb3RlOgo+IEhpIEFuZHJl
YXMgYW5kIERpbmggIFRoYW5rcyBmb3IgeW91ciBmZWVkYmFjayBpIHdpbGwgY2hlY2sgaXQuCgpo
bW0sIEkgd2FzIGxvb2tpbmcgYXQgdGhlIGNvZGUgYW5kIGluZGVlZCBJIGhhdmUgc29tZSBkb3Vi
dCBvbgptZGlvX2J1c19kYXRhIG1hbmFnZW1lbnQgdGhhdCB0aGUgcGF0Y2ggY2hhbmdlcyBleHBs
YWluaW5nCndoeSB0aGUgQW5kcmVhcydzIGJveCBmYWlscyBhbmQgcGh5X2FkZCBpcyBub3QgZGV0
ZWN0ZWQuCgpLZWVwIHRoZSBzeW5jCgpwZXBwZQoKCj4gQmVzdCByZWdhcmRzCj4KPiBHYWJyaWVs
Cj4KPiBPbiA4IE1hcmNoIDIwMTYgYXQgMDA6MjIsIERpbmggTmd1eWVuIDxkaW5oLmxpbnV4QGdt
YWlsLmNvbT4gd3JvdGU6Cj4+IE9uIE1vbiwgTWFyIDcsIDIwMTYgYXQgMTE6MTUgQU0sIEFuZHJl
YXMgRsOkcmJlciA8YWZhZXJiZXJAc3VzZS5kZT4gd3JvdGU6Cj4+PiBBbSAwNy4wMy4yMDE2IHVt
IDE2OjUyIHNjaHJpZWIgR2l1c2VwcGUgQ0FWQUxMQVJPOgo+Pj4+IE9uIDMvNy8yMDE2IDQ6NDYg
UE0sIEFuZHJlYXMgRsOkcmJlciB3cm90ZToKPj4+Pj4gQW0gMDcuMDMuMjAxNiB1bSAxNjowOSBz
Y2hyaWViIEdpdXNlcHBlIENBVkFMTEFSTzoKPj4+Pj4+IE9uIDMvNy8yMDE2IDM6MjcgUE0sIEFu
ZHJlYXMgRsOkcmJlciB3cm90ZToKPj4+Pj4+PiBJbmRlZWQsIHJldmVydGluZyBHYWJyaWVsJ3Mg
Y29tbWl0IGZpeGVzIHRoZSBvYnNlcnZlZCBlcnJvciBtZXNzYWdlcwo+Pj4+PiBbLi4uXQo+Pj4+
Pj4+IEhvd2V2ZXIsIEkgYW0gdW5hYmxlIHRvIHBpbmcgYW55IGhvc3RzIG9uIHRoZSBuZXR3b3Jr
IG5vdy4KPj4+Pj4+Cj4+Pj4+PiBobW0sIHRoaXMgY291bGQgYmUgYW5vdGhlciBwcm9ibGVtLiBJ
IHdvbmRlciBpZiB5b3UgY2FuCj4+Pj4+PiBjaGVjayB3aGljaCByZWNlbnQgcGF0Y2ggaXMgaW50
cm9kdWNpbmcgdGhlIHByb2JsZW0gb24gQVJNNjQuCj4+Pj4+PiBGb3IgZXhhbXBsZSBpZiB0aGlz
IGRlcGVuZHMgb24gT2N0XzIwMTUgdXBkYXRlLgo+Pj4+Pgo+Pj4+PiBJJ3ZlIGhhZCBzdWNjZXNz
IHJldmVydGluZyBkcml2ZXJzL25ldC9ldGhlcm5ldC9zdG1pY3JvLyB1cCB0byBhbmQKPj4+Pj4g
aW5jbHVkaW5nICJzdG1tYWM6IGZpcnN0IGZyYW1lIHByZXAgYXQgdGhlIGVuZCBvZiB4bWl0IHJv
dXRpbmUiLCBpLmUuCj4+Pj4+IHRvcCA3IGNvbW1pdHMuCj4+Pj4KPj4+PiBBbmRyZWFzLCBJIHdp
bGwgY2hlY2sgaXQgYW5kIGxldCB5b3Uga25vdyBhc2FwLgo+Pj4KPj4+IEkgdmVyaWZpZWQgdGhh
dCBpdCdzIGp1c3QgdGhlc2UgdHdvIGNvbW1pdHMgdGhhdCBJIG5lZWQgdG8gcmV2ZXJ0Ogo+Pj4K
Pj4+ICJzdG1tYWM6IEZpeCAnZXRoMDogTm8gUEhZIGZvdW5kJyByZWdyZXNzaW9uIgo+Pj4gInN0
bW1hYzogZmlyc3QgZnJhbWUgcHJlcCBhdCB0aGUgZW5kIG9mIHhtaXQgcm91dGluZSIKPj4+Cj4+
PiBUaG9zZSBpbiBiZXR3ZWVuIGRvbid0IGNhdXNlIGNvbmZsaWN0cyBhbmQgc2VlbSB0byB3b3Jr
IG9rYXkuCj4+Pgo+Pgo+PiBJJ20gc2VlaW5nIHRoZSBzYW1lIGlzc3VlIG9uIHRoZSBTb0NGUEdB
IHBsYXRmb3JtOgo+Pgo+PiBsaWJwaHk6IFBIWSBzdG1tYWMtMDpmZmZmZmZmZiBub3QgZm91bmQK
Pj4gZXRoMDogQ291bGQgbm90IGF0dGFjaCB0byBQSFkKPj4gc3RtbWFjX29wZW46IENhbm5vdCBh
dHRhY2ggdG8gUEhZIChlcnJvcjogLTE5KQo+Pgo+PiBJZiBJIGp1c3QgcmV2ZXJ0Ogo+Pgo+PiAg
ICJzdG1tYWM6IEZpeCAnZXRoMDogTm8gUEhZIGZvdW5kJyByZWdyZXNzaW9uIgo+Pgo+PiB0aGVu
IHRoZSBpc3N1ZSBnb2VzIGF3YXkuCj4+Cj4+IFRoYW5rcywKPj4gRGluaAo+Cj4KCgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eC1yb2NrY2hpcCBt
YWlsaW5nIGxpc3QKTGludXgtcm9ja2NoaXBAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlz
dHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LXJvY2tjaGlwCg==
