From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 20:24:01 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C19879@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <20160718154512.GK5871@two.firstfloor.org>
 <CAM_iQpVRfoC0e43Pbsw8Q3RsyDDnMZeGu=oS0iVvAfMNwz6DeA@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07712C19852@SHSMSX103.ccr.corp.intel.com>
 <CAM_iQpXWVGh6dsj5jSasi-Oy7w7dzB_z-vxT_Ot363_BXZpM2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Andi Kleen <andi@firstfloor.org>, Florian Westphal <fw@strlen.de>,
	"David Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kees Cook" <keescook@chromium.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Cyrill Gorcunov" <gorcunov@openvz.org>,
	John Stultz <john.stultz@linaro.org>,
	"Alex Duyck" <aduyck@mirantis.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"Brandeburg, Jesse" <jes
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXWVGh6dsj5jSasi-Oy7w7dzB_z-vxT_Ot363_BXZpM2A@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gPj4NCj4gPj4gT24gTW9uLCBKdWwgMTgsIDIwMTYgYXQgODo0NSBBTSwgQW5kaSBLbGVl
biA8YW5kaUBmaXJzdGZsb29yLm9yZz4gd3JvdGU6DQo+ID4+ID4+IEl0IHNlZW1zIHN0cmFuZ2Ug
dG8gbWUgdG8gYWRkIHN1Y2ggcG9saWNpZXMgdG8gdGhlIGtlcm5lbC4NCj4gPj4gPj4gQWRkbWl0
dGluZ2x5LCBkb2N1bWVudGF0aW9uIG9mIHNvbWUgc2V0dGluZ3MgaXMgbm9uLWV4aXN0ZW50IGFu
ZA0KPiA+PiA+PiBvbmUgbmVlZHMgdmFyaW91cyBkaWZmZXJlbnQgdG9vbHMgdG8gc2V0IHRoaXMg
KHN5c2N0bCwgcHJvY2ZzLCBzeXNmcywNCj4gZXRodG9vbCwgZXRjKS4NCj4gPj4gPg0KPiA+PiA+
IFRoZSBwcm9ibGVtIGlzIHRoYXQgZGlmZmVyZW50IGFwcGxpY2F0aW9ucyBuZWVkIGRpZmZlcmVu
dCBwb2xpY2llcy4NCj4gPj4gPg0KPiA+PiA+IFRoZSBvbmx5IGVudGl0eSB3aGljaCBjYW4gZWZm
aWNpZW50bHkgbmVnb3RpYXRlIGJldHdlZW4gZGlmZmVyZW50DQo+ID4+ID4gYXBwbGljYXRpb25z
JyBjb25mbGljdGluZyByZXF1ZXN0cyBpcyB0aGUga2VybmVsLiBBbmQgdGhhdCBpcw0KPiA+PiA+
IHByZXR0eSBtdWNoIHRoZSBiYXNpYyBqb2IgZGVzY3JpcHRpb24gb2YgYSBrZXJuZWw6IG11bHRp
cGxleA0KPiA+PiA+IGhhcmR3YXJlIGVmZmljaWVudGx5IGJldHdlZW4gZGlmZmVyZW50IHVzZXJz
Lg0KPiA+PiA+DQo+ID4+ID4gU28geWVzIHRoZSB1c2VyIHNwYWNlIHR1bmluZyBhcHByb2FjaCB3
b3JrcyBmb3Igc2ltcGxlIGNhc2VzICgib25seQ0KPiA+PiA+IHJ1biB3b3JrbG9hZHMgdGhhdCBy
ZXF1aXJlIHRoZSBzYW1lIHR1bmluZyIpLCBidXQgaXMgdWx0aW1hdGVseSBub3QNCj4gPj4gPiB2
ZXJ5IGludGVyZXN0aW5nIG5vciBzY2FsYWJsZS4NCj4gPj4NCj4gPj4gSSBkb24ndCByZWFkIHRo
ZSBjb2RlIHlldCwganVzdCB0aGUgY292ZXIgbGV0dGVyLg0KPiA+Pg0KPiA+PiBXZSBoYXZlIGds
b2JhbCB0dW5pbmdzLCBwZXItbmV0d29yay1uYW1lc3BhY2UgdHVuaW5ncywgcGVyLXNvY2tldA0K
PiB0dW5pbmdzLg0KPiA+PiBJdCBpcyBzdGlsbCB1bmNsZWFyIHdoeSB5b3UgY2FuJ3QganVzdCBw
dXQgZGlmZmVyZW50IGFwcGxpY2F0aW9ucw0KPiA+PiBpbnRvIGRpZmZlcmVudCBuYW1lc3BhY2Vz
L2NvbnRhaW5lcnMgdG8gZ2V0IGRpZmZlcmVudCBwb2xpY2llcy4NCj4gPg0KPiA+IEluIE5FVCBw
b2xpY3ksIHdlIGRvIHBlciBxdWV1ZSB0dW5pbmdzLg0KPiANCj4gSXMgaXQgcG9zc2libGUgdG8g
aXNvbGF0ZSBOSUMgcXVldWVzIGZvciBjb250YWluZXJzPw0KDQpZZXMsIGJ1dCB3ZSBkb24ndCAg
aGF2ZSBjb250YWluZXJzIHN1cHBvcnQgeWV0LiANCg==
