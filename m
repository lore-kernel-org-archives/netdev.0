From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network
 performance after a while.
Date: Tue, 09 Feb 2010 08:36:17 +0100
Message-ID: <1265700977.4236.127.camel@edumazet-laptop>
References: <bug-15239-10286@http.bugzilla.kernel.org/>
	<20100208141513.b5d0be56.akpm@linux-foundation.org>
	<20100208.145531.143618406.davem@davemloft.net>
	<4B710C93.9010603@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: pstaszewski@artcom.pl, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	stable@kernel.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, bugme-daemon@bugzilla.kernel.org,
	akpm@linux-foundation.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4B710C93.9010603@itcare.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TGUgbWFyZGkgMDkgZsOpdnJpZXIgMjAxMCDDoCAwODoxOSArMDEwMCwgUGF3ZcWCIFN0YXN6ZXdz
a2kgYSDDqWNyaXQgOgo+IFcgZG5pdSAyMDEwLTAyLTA4IDIzOjU1LCBEYXZpZCBNaWxsZXIgcGlz
emU6Cj4gPiBGcm9tOiBBbmRyZXcgTW9ydG9uPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+Cj4g
PiBEYXRlOiBNb24sIDggRmViIDIwMTAgMTQ6MTU6MTMgLTA4MDAKPiA+Cj4gPiAgICAKPiA+PiBU
aGF0IHdvdWxkIGJlIGJhZC4gIFRoYXQncyBhIHJlZ3Jlc3Npb24gaW4gMi42LjMzLXJjLCBhbmQg
d2UndmUKPiA+PiBiYWNrcG9ydGVkIHRoYXQgcmVncmVzc2lvbiBpbnRvIDIuNi4zMi54IC1zdGFi
bGUuCj4gPj4gICAgICAKPiA+IEx1Y2tpbHkgd2UgaGF2ZSBhIGZpeCBhbHJlYWR5LiA6LSkKPiA+
ICAgIAo+IAo+IFllcyAtIGkgbWFrZSBidWdyZXBvcnQgYW5kIGFmdGVyIGkgd3JpdGUgYWxzbyBo
ZXJlIG9uIHRoZSBsaXN0Cj4gCj4gQW5kIEVyaWMgRHVtYXpldCBoZWxwIHRvIHNvbHZlIHByb2Js
ZW0gd2l0aCAicm91dGUgY2FjaGUiIC0gYW5kIGxvY2tpbmcgCj4gbG9hZCBvbiBvbmUgY3B1IGFm
dGVyIGluZm9ybWF0aW9uIGFib3V0ICJyb3V0ZSBjYWNoZSBkaXNhYmxlZCIuCj4gCj4gQWZ0ZXIg
aGlzIHBhdGNoIGkgZG9uJ3Qgc2VlIGFueSBlcnJvcnMgaW4gZG1lc2cuCj4gCgpPSywgYnV0IHRo
aXMgaXMgcmVhbCBvbGQgYnVnIChzaW5jZSAyLjYuMjQpLCBub3QgYSAyLjYuMzIvMi42LjMzCnJl
Z3Jlc3Npb24uLi4KCllvdSB3ZXJlIGp1c3QgbHVja3kgbm90IGhpdHRpbmcgaXQgYmVmb3JlLCBw
cm9iYWJseSBiZWNhdXNlIHlvdSB0cmllZApkaWZmZXJlbnQgc2V0dGluZ3MuCgoKCgotLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0KVGhlIFBsYW5ldDogZGVkaWNhdGVkIGFuZCBtYW5hZ2VkIGhvc3Rpbmcs
IGNsb3VkIHN0b3JhZ2UsIGNvbG9jYXRpb24KU3RheSBvbmxpbmUgd2l0aCBlbnRlcnByaXNlIGRh
dGEgY2VudGVycyBhbmQgdGhlIGJlc3QgbmV0d29yayBpbiB0aGUgYnVzaW5lc3MKQ2hvb3NlIGZs
ZXhpYmxlIHBsYW5zIGFuZCBtYW5hZ2VtZW50IHNlcnZpY2VzIHdpdGhvdXQgbG9uZy10ZXJtIGNv
bnRyYWN0cwpQZXJzb25hbCAyNHg3IHN1cHBvcnQgZnJvbSBleHBlcmllbmNlIGhvc3RpbmcgcHJv
cyBqdXN0IGEgcGhvbmUgY2FsbCBhd2F5LgpodHRwOi8vcC5zZi5uZXQvc2Z1L3RoZXBsYW5ldC1j
b20KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KRTEwMDAt
ZGV2ZWwgbWFpbGluZyBsaXN0CkUxMDAwLWRldmVsQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRw
czovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9lMTAwMC1kZXZlbApUbyBs
ZWFybiBtb3JlIGFib3V0IEludGVsJiMxNzQ7IEV0aGVybmV0LCB2aXNpdCBodHRwOi8vY29tbXVu
aXRpZXMuaW50ZWwuY29tL2NvbW11bml0eS93aXJlZAo=
