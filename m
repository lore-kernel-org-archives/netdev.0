From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net 1/2] xen-netback: keep a local pointer
 for vif in backend_disconnect()
Date: Thu, 2 Mar 2017 13:35:02 +0000
Message-ID: <20170302133501.iozb3f3ex6gaarqt@citrix.com>
References: <1488459266-29269-1-git-send-email-paul.durrant@citrix.com>
 <1488459266-29269-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
 xen-devel@lists.xenproject.org
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1488459266-29269-2-git-send-email-paul.durrant@citrix.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gVGh1LCBNYXIgMDIsIDIwMTcgYXQgMTI6NTQ6MjVQTSArMDAwMCwgUGF1bCBEdXJyYW50IHdy
b3RlOgo+IFRoaXMgcGF0Y2ggcmVwbGFjZXMgdXNlIG9mICdiZS0+dmlmJyB3aXRoICd2aWYnIGFu
ZCBoZW5jZSBnZW5lcmFsbHkKPiBtYWtlcyB0aGUgZnVuY3Rpb24gbG9vayB0aWRpZXIuIE5vIHNl
bWFudGljIGNoYW5nZS4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBQYXVsIER1cnJhbnQgPHBhdWwuZHVy
cmFudEBjaXRyaXguY29tPgoKQWNrZWQtYnk6IFdlaSBMaXUgPHdlaS5saXUyQGNpdHJpeC5jb20+
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2
ZWwgbWFpbGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVu
Lm9yZy94ZW4tZGV2ZWwK
