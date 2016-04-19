From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2 2/4] io-mapping: Specify mapping size for
 io_mapping_map_wc()
Date: Tue, 19 Apr 2016 13:34:59 +0100
Message-ID: <20160419123459.GB14602@nuc-i3427.alporthouse.com>
References: <1460978042-9953-1-git-send-email-chris@chris-wilson.co.uk>
 <1460978042-9953-2-git-send-email-chris@chris-wilson.co.uk>
 <20160419120225.GF26039@nuc-i3427.alporthouse.com>
 <20160419123028.GI1990@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
 intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org,
 Ingo Molnar <mingo@kernel.org>,
 "Peter Zijlstra \(Intel\)" <peterz@infradead.org>,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 Daniel Vetter <daniel.vetter@intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Yishai Hadas <yishaih@mellanox.com>,
 David Hildenbrand <dahi@linux.vnet.ibm.com>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20160419123028.GI1990@wotan.suse.de>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gVHVlLCBBcHIgMTksIDIwMTYgYXQgMDI6MzA6MjhQTSArMDIwMCwgTHVpcyBSLiBSb2RyaWd1
ZXogd3JvdGU6Cj4gT24gVHVlLCBBcHIgMTksIDIwMTYgYXQgMDE6MDI6MjVQTSArMDEwMCwgQ2hy
aXMgV2lsc29uIHdyb3RlOgo+ID4gT24gTW9uLCBBcHIgMTgsIDIwMTYgYXQgMTI6MTQ6MDBQTSAr
MDEwMCwgQ2hyaXMgV2lsc29uIHdyb3RlOgo+ID4gPiBUaGUgaW9yZW1hcCgpIGhpZGRlbiBiZWhp
bmQgdGhlIGlvX21hcHBpbmdfbWFwX3djKCkgY29udmVuaWVuY2UgaGVscGVyCj4gPiA+IGNhbiBi
ZSB1c2VkIGZvciByZW1hcHBpbmcgbXVsdGlwbGUgcGFnZXMuIEV4dGVuZCB0aGUgaGVscGVyIHNv
IHRoYXQKPiA+ID4gZnV0dXJlIGNhbGxlcnMgY2FuIHVzZSBpdCBmb3IgbGFyZ2VyIHJhbmdlcy4K
PiA+IAo+ID4gQWRkaW5nIEx1aXMgUm9kcmlndWV6IGFzIGhlIGhhcyBiZWVuIGFjdGl2ZSBpbiB0
aGUgYXJlYSBvZiBpb3JlbWFwXyooKS4KPiAKPiBDYW4gc29tZW9uZSBib3VuY2UgbWUgYSBjb3B5
IG9mIHRoZSBvcmlnaW5hbCBlLW1haWxzPyBDYW4geW91IGFsc28gdXNlCj4gbWNncm9mQGtlcm5l
bC5vcmcgPwoKSG9wZWZ1bGx5IGRvbmUuIFBsZWFzZSBwaW5nIG1lIGlmIHRoZXkgZG9uJ3QgYXJy
aXZlLCBvciBoYXZlIGEgbG9vayBhdApodHRwczovL2NnaXQuZnJlZWRlc2t0b3Aub3JnL35pY2ts
ZS9saW51eC0yLjYvbG9nLz9oPWlvbWFwCi1DaHJpcwoKLS0gCkNocmlzIFdpbHNvbiwgSW50ZWwg
T3BlbiBTb3VyY2UgVGVjaG5vbG9neSBDZW50cmUKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlz
dHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4v
bGlzdGluZm8vaW50ZWwtZ2Z4Cg==
