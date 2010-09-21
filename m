From: Priit Laes <plaes@plaes.org>
Subject: Re: REGRESSION: e1000e fails to communicate in
	2.6.36-rcx (82566DM)
Date: Tue, 21 Sep 2010 10:26:58 +0300
Message-ID: <1285054018.1487.28.camel@chi>
References: <1283806304.6947.13.camel@chi>
	<EA929A9653AAE14F841771FB1DE5A1366008739474@rrsmsx501.amr.corp.intel.com>
	<1284112667.10960.3.camel@chi>
	<EA929A9653AAE14F841771FB1DE5A1366008789CE3@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1366008789CE3@rrsmsx501.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

w5xoZWwga2VuYWwgcMOkZXZhbCwgUiwgMjAxMC0wOS0xMCBrZWxsIDExOjIxLCBraXJqdXRhcyBU
YW50aWxvdiwgRW1pbCBTOgo+ID4+ID4gQWZ0ZXIgdHJ5aW5nIG91dCBuZXdlciAyLjYuMzUtcmMz
IGtlcm5lbCwgdGhlIG5ldHdvcmsgaW50ZXJmYWNlIGZhaWxzCj4gPj4gPiB0bwo+ID4KPiA+VWhv
aC4uIGl0IHdhcyBhIHR5cG8gXl4sIHJlYWwga2VybmVsIHZlcnNpb24gaXMgMi42LjM2LXJjMysg
OlMKPiA+Cj4gPj4gSXMgdGhpcyBzdGlsbCBhbiBpc3N1ZSBpbiB0aGUgbGF0ZXN0IG5ldC1uZXh0
IHB1bGw/Cj4gPlllcywgaXQgaXMgc3RpbGwgbm90IHdvcmtpbmcgKGxhdGVzdCBuZXQtbmV4dCBw
dWxsIHdhcyBvbiA0dGggb2YgQXVnKQo+ID4KPiA+PiBBbHNvIHBsZWFzZSBwcm92aWRlIHRoZSBv
dXRwdXQgb2YgZXRodG9vbCAtZS4KPiA+Cj4gPkF0dGFjaGVkIG91dHB1dCBmcm9tIDIuNi4zNi1y
YzMKPiAKPiBJIHRoaW5rIHRoaXMgaXMgYSBrbm93biBpc3N1ZSBmb3IgdGhpcyBkZXZpY2UgLSB3
ZSBoYXZlIGEgcGF0Y2ggY3VycmVudGx5IAo+IGluIHRlc3QsIGFuZCB3ZSBzaG91bGQgaGF2ZSBp
dCBvdXQgc29vbi4KCkFueSBuZXdzIG9uIHRoZSBwYXRjaD8KCjIuNi4zNi1yYzUgaXMgYWxyZWFk
eSBvdXQgYW5kIEkgcmVhbGx5IGRvIG5vdCB3YW50IHRvIHNlZSBpdCBnZXR0aW5nCmludG8gbWFq
b3IgcmVsZWFzZSA6KAoKQ2hlZXJzLApQcmlpdCA6KQoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClN0
YXJ0IHVuY292ZXJpbmcgdGhlIG1hbnkgYWR2YW50YWdlcyBvZiB2aXJ0dWFsIGFwcGxpYW5jZXMK
YW5kIHN0YXJ0IHVzaW5nIHRoZW0gdG8gc2ltcGxpZnkgYXBwbGljYXRpb24gZGVwbG95bWVudCBh
bmQKYWNjZWxlcmF0ZSB5b3VyIHNoaWZ0IHRvIGNsb3VkIGNvbXB1dGluZy4KaHR0cDovL3Auc2Yu
bmV0L3NmdS9ub3ZlbGwtc2ZkZXYyZGV2Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCkUxMDAwLWRldmVsIG1haWxpbmcgbGlzdApFMTAwMC1kZXZlbEBsaXN0
cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlz
dGluZm8vZTEwMDAtZGV2ZWwKVG8gbGVhcm4gbW9yZSBhYm91dCBJbnRlbCYjMTc0OyBFdGhlcm5l
dCwgdmlzaXQgaHR0cDovL2NvbW11bml0aWVzLmludGVsLmNvbS9jb21tdW5pdHkvd2lyZWQK
