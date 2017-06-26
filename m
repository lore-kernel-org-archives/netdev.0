From: Christoph Hellwig <hch@lst.de>
Subject: Re: new dma-mapping tree, was Re: clean up and modularize arch
 dma_mapping interface V2
Date: Mon, 26 Jun 2017 09:03:50 +0200
Message-ID: <20170626070350.GB10544@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
 <20170620124140.GA27163@lst.de> <20170620230400.1a5ae889@canb.auug.org.au>
 <CGME20170620131628epcas1p4f21d821bd414cba7e2d49abcbe414365@epcas1p4.samsung.com>
 <20170620131623.GB30769@lst.de>
 <5425587c-73e8-e24a-86a3-8a65a7791dcb@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org,
 sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 Stephen Rothwell <sfr@canb.auug.org.au>, linux-samsung-soc@vger.kernel.org,
 linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org,
 Kyungmin Park <kyungmin.park@samsung.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org,
 linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org,
 openrisc@lists.librecores.org, linux-tegra@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
 dmaengine@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Marek Szyprowski <m.szyprowski@samsung.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <5425587c-73e8-e24a-86a3-8a65a7791dcb@samsung.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gV2VkLCBKdW4gMjEsIDIwMTcgYXQgMDM6MzI6MzlQTSArMDIwMCwgTWFyZWsgU3p5cHJvd3Nr
aSB3cm90ZToKPiBsaW51eC1uZXh0Cj4gd2FzIGEgc2lkZSBlZmZlY3Qgb2YgdGhhdC4gSSB0aGlu
ayB0aGF0IGZvciBub3cgaXQgY2FuIGJlIGRyb3BwZWQgaW4gZmF2b3IgCj4gb2YKPiBDaHJpc3Rv
cGgncyB0cmVlLiBJIGNhbiBhbHNvIGRvIHNvbWUgcmV2aWV3IGFuZCBoZWxwIGluIG1haW50YWlu
ZXJzIHdvcmsgaWYKPiBuZWVkZWQsIGFsdGhvdWdoIEkgd2FzIHJlY2VudGx5IGJ1c3kgd2l0aCBv
dGhlciBzdHVmZi4KPgo+IENocmlzdG9waDogQ291bGQgeW91IGFkZCBtZSB0byB5b3VyIE1BSU5U
QUlORVJTIHBhdGNoLCBzbyBmdXJ0aGVyIAo+IGRtYS1tYXBwaW5nCj4gcmVsYXRlZCBwYXRjaGVz
IGhvcGVmdWxseSB3aWxsIGJlIGFsc28gQ0M6IHRvIG1lPwoKSSd2ZSBhZGRlZCB5b3UgYXMgYSBj
by1tYWludGFpbmVyLCB0aGFua3MhCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVk
ZXNrdG9wLm9yZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZv
L2RyaS1kZXZlbAo=
