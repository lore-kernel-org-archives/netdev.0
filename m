From: Christoph Hellwig <hch@lst.de>
Subject: Re: new dma-mapping tree, was Re: clean up and modularize arch
 dma_mapping interface V2
Date: Tue, 20 Jun 2017 15:15:03 +0200
Message-ID: <20170620131503.GA30769@lst.de>
References: <20170620124140.GA27163@lst.de>
 <6025d4d4-1975-9598-c16d-26d17d029ec7@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, dri-devel@lists.freedesktop.org,
 sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 Stephen Rothwell <sfr@canb.auug.org.au>, linux-samsung-soc@vger.kernel.org,
 linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org,
 linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org,
 openrisc@lists.librecores.org, linux-tegra@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
 dmaengine@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <6025d4d4-1975-9598-c16d-26d17d029ec7@arm.com>
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

T24gVHVlLCBKdW4gMjAsIDIwMTcgYXQgMDI6MTQ6MzZQTSArMDEwMCwgUm9iaW4gTXVycGh5IHdy
b3RlOgo+IEhpIENocmlzdG9waCwKPiAKPiBPbiAyMC8wNi8xNyAxMzo0MSwgQ2hyaXN0b3BoIEhl
bGx3aWcgd3JvdGU6Cj4gPiBPbiBGcmksIEp1biAxNiwgMjAxNyBhdCAwODoxMDoxNVBNICswMjAw
LCBDaHJpc3RvcGggSGVsbHdpZyB3cm90ZToKPiA+PiBJIHBsYW4gdG8gY3JlYXRlIGEgbmV3IGRt
YS1tYXBwaW5nIHRyZWUgdG8gY29sbGVjdCBhbGwgdGhpcyB3b3JrLgo+ID4+IEFueSB2b2x1bnRl
ZXJzIGZvciBjby1tYWludGFpbmVycywgZXNwZWNpYWxseSBmcm9tIHRoZSBpb21tdSBnYW5nPwo+
ID4gCj4gPiBPaywgSSd2ZSBjcmVhdGVkIHRoZSBuZXcgdHJlZToKPiA+IAo+ID4gICAgZ2l0Oi8v
Z2l0LmluZnJhZGVhZC5vcmcvdXNlcnMvaGNoL2RtYS1tYXBwaW5nLmdpdCBmb3ItbmV4dAo+ID4g
Cj4gPiBHaXR3ZWI6Cj4gPiAKPiA+ICAgIGh0dHA6Ly9naXQuaW5mcmFkZWFkLm9yZy91c2Vycy9o
Y2gvZG1hLW1hcHBpbmcuZ2l0L3Nob3J0bG9nL3JlZnMvaGVhZHMvZm9yLW5leHQKPiA+IAo+ID4g
QW5kIGJlbG93IGlzIHRoZSBwYXRjaCB0byBhZGQgdGhlIE1BSU5UQUlORVJTIGVudHJ5LCBhZGRp
dGlvbnMgd2VsY29tZS4KPiAKPiBJJ20gaGFwcHkgdG8gYmUgYSByZXZpZXdlciwgc2luY2UgSSd2
ZSBiZWVuIHdvcmtpbmcgaW4gdGhpcyBhcmVhIGZvcgo+IHNvbWUgdGltZSwgcGFydGljdWxhcmx5
IHdpdGggdGhlIGRtYS1pb21tdSBjb2RlIGFuZCBhcm02NCBETUEgb3BzLgoKR3JlYXQsIEknbGwg
YWRkIHlvdSEKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
ZHJpLWRldmVsIG1haWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0
dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vZHJpLWRldmVsCg==
