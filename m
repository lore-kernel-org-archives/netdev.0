From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Fri, 10 Feb 2017 13:46:42 -0500 (EST)
Message-ID: <20170210.134642.410630778303927589.davem@davemloft.net>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
 <bc3bf927-568e-043a-2785-16e6c3628359@suse.com>
 <fa4ea104-4283-e707-019e-dee89dc66f3e@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: jgross@suse.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org, vineethp@amazon.com,
 xen-devel@lists.xenproject.org, paul.durrant@citrix.com
To: boris.ostrovsky@oracle.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <fa4ea104-4283-e707-019e-dee89dc66f3e@oracle.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RnJvbTogQm9yaXMgT3N0cm92c2t5IDxib3Jpcy5vc3Ryb3Zza3lAb3JhY2xlLmNvbT4KRGF0ZTog
VGh1LCA5IEZlYiAyMDE3IDA4OjQyOjU5IC0wNTAwCgo+IEFyZSB5b3UgZ29pbmcgdG8gdGFrZSB0
aGlzIHRvIHlvdXIgdHJlZSBvciB3b3VsZCB5b3UgcmF0aGVyIGl0IGdvZXMKPiB2aWEgWGVuIHRy
ZWU/CgpPaywgSSBqdXN0IGRpZC4KCj4gQW5kIHRoZSBzYW1lIHF1ZXN0aW9uIGZvcgo+IAo+IGh0
dHBzOi8vbGlzdHMueGVucHJvamVjdC5vcmcvYXJjaGl2ZXMvaHRtbC94ZW4tZGV2ZWwvMjAxNy0w
Mi9tc2cwMDYyNS5odG1sCgpBcyBJIHN0YXRlZCBpbiB0aGUgdGhyZWFkLCBJIGFwcGxpZWQgdGhp
cyBvbmUuCgo+IGh0dHBzOi8vbGlzdHMueGVucHJvamVjdC5vcmcvYXJjaGl2ZXMvaHRtbC94ZW4t
ZGV2ZWwvMjAxNy0wMi9tc2cwMDc1NC5odG1sCgpMaWtld2lzZS4KCkluIHRoZSBmdXR1cmUsIGlm
IHlvdSB1c2UgbmV0ZGV2IHBhdGNod29yayBVUkxzLCB0d28gdGhpbmdzIHdpbGwKaGFwcGVuLiAg
WW91IHdpbGwgc2VlIGltbWVkaWF0ZWx5IGluIHRoZSBkaXNjdXNzaW9uIGxvZyBhbmQgdGhlIHBh
dGNoCnN0YXRlIHdoZXRoZXIgSSBhcHBsaWVkIGl0IG9yIG5vdC4gIEFuZCBzZWNvbmQsIEkgd2ls
bCBiZSBhYmxlIHRvCnJlZmVyZW5jZSBhbmQgZG8gc29tZXRoaW5nIHdpdGggdGhlIHBhdGNoIHRo
YXQgbXVjaCBtb3JlIHF1aWNrbHkKYW5kIGVhc2lseS4KClRoYW5rIHlvdS4KCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxp
c3QKWGVuLWRldmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZl
bAo=
