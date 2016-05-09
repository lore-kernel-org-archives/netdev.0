From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: Re: [PATCH net-next 2/4] xen-netback: add control
 protocol implementation
Date: Mon, 9 May 2016 08:56:44 +0000
Message-ID: <cf95797a1a964e2ea6c525d7070f6f94@AMSPEX02CL03.citrite.net>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
 <20160507.150921.2053537729453518863.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
 Wei Liu <wei.liu2@citrix.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20160507.150921.2053537729453518863.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQo+IEZyb206IERhdmlkIE1pbGxlciBbbWFpbHRv
OmRhdmVtQGRhdmVtbG9mdC5uZXRdCj4gU2VudDogMDcgTWF5IDIwMTYgMjA6MDkKPiBUbzogUGF1
bCBEdXJyYW50Cj4gQ2M6IHhlbi1kZXZlbEBsaXN0cy54ZW5wcm9qZWN0Lm9yZzsgbmV0ZGV2QHZn
ZXIua2VybmVsLm9yZzsgV2VpIExpdQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHQgMi80
XSB4ZW4tbmV0YmFjazogYWRkIGNvbnRyb2wgcHJvdG9jb2wKPiBpbXBsZW1lbnRhdGlvbgo+IAo+
IEZyb206IFBhdWwgRHVycmFudCA8cGF1bC5kdXJyYW50QGNpdHJpeC5jb20+Cj4gRGF0ZTogVGh1
LCA1IE1heSAyMDE2IDEyOjE5OjI4ICswMTAwCj4gCj4gPiArc3RydWN0IHhlbnZpZl9oYXNoX2Nh
Y2hlIHsKPiA+ICsJcndsb2NrX3QgbG9jazsKPiAKPiBZb3UgcmVhbGx5IGRvbid0IHdhbnQgdG8g
bG9jayBvbiBldmVyeSBTS0IgaGFzaCBjb21wdXRhdGlvbiBsaWtlCj4gdGhpcywgdHVybiB0aGlz
IGludG8gYSBzcGluIGxvY2sgZm9yIGxvY2tpbmcgdGhlIHdyaXRlIHNpZGUgYW5kCj4gdXNlIFJD
VSBsb2NraW5nIGZvciBsb29rdXAgYW5kIHVzYWdlLgo+CgpZZXMsIHRoYXQgd291bGQgYmUgYmV0
dGVyLiBXaWxsIGRvLgoKQ2hlZXJzLAoKICBQYXVsCiAKPiBUSGFua3MuCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0
Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHA6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
