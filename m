From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Mon, 30 Jan 2017 12:06:34 -0500
Message-ID: <30069778-9509-8112-5089-2eea7b679236@oracle.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
 <38ccfaea-0a65-a6f3-c19a-e6f9c0d4ef76@oracle.com>
 <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, Paul Durrant <paul.durrant@citrix.com>,
 Wei Liu <wei.liu2@citrix.com>, David Miller <davem@davemloft.net>,
 xen-devel <xen-devel@lists.xen.org>
To: Vineeth Remanan Pillai <vineethp@amazon.com>, linux-kernel@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gMDEvMzAvMjAxNyAxMTo0NyBBTSwgVmluZWV0aCBSZW1hbmFuIFBpbGxhaSB3cm90ZToKPgo+
PiAyLiBJdCB0aWNrbGVzIGEgbGF0ZW50IGJ1ZyBkdXJpbmcgcmVzdW1lIHdoZXJlIHRoZSB0aW1l
ciB0cmlnZ2Vycwo+PiBiZWZvcmUgd2UgcmUtY29ubmVjdC4gVGhlIHRyb3VibGUgaXMgdGhhdCB3
ZSBub3cgdHJ5IHRvIGRlcmVmZXJlbmNlCj4+IHF1ZXVlLT5yeC5zcmluZyB3aGljaCBpcyBOVUxM
IHNpbmNlIHdlIGRpc2Nvbm5lY3QgaW4KPj4gbmV0ZnJvbnRfcmVzdW1lKCkuIChDdXJpb3VzbHks
IEkgb25seSBvYnNlcnZlIGl0IHdpdGggMzItYml0IGd1ZXN0cykKPiBJIHRoaW5rIHdlIG1heSBo
aXQgdGhpcyBidWcgYWZ0ZXIgcmVtb3ZpbmcgdGhlIHRpbWVyIGFzIHdlbGwuIFdlIGNhbGwKPiBS
SU5HX1BVU0hfUkVRVUVTVFNfQU5EX0NIRUNLX05PVElGWSBzb29uIGFmdGVyLCB3aGljaCBhbHNv
IGRlcmVmZXJlbmNlCj4gcXVldWUtPnJ4LnNyaW5nLgoKCklmIHRoZSB0aW1lciBpcyBkZWxldGVk
IGluIHhlbm5ldF9kaXNjb25uZWN0X2JhY2tlbmQoKSB0aGVuIHdoeSB3b3VsZAphbnlvbmUgYmUg
cHVzaGluZyBhbnl0aGluZyB0byB0aGUgYmFja2VuZCBhZnRlciB0aGF0PwoKLWJvcmlzCgpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFp
bGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94
ZW4tZGV2ZWwK
