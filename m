From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 21/62] net: remove the second argument of
	k[un]map_atomic()
Date: Mon, 28 Nov 2011 15:39:43 +0800
Message-ID: <4ED33ABF.7000203@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
	<1322371662-26166-22-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jiri Pirko <jpirko@redhat.com>, Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	Dean Nelson <dnelson@redhat.com>, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Cong Wang <amwang@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1322371662-26166-22-git-send-email-amwang@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

5LqOIDIwMTHlubQxMeaciDI35pelIDEzOjI3LCBDb25nIFdhbmcg5YaZ6YGTOgo+IFNpZ25lZC1v
ZmYtYnk6IENvbmcgV2FuZzxhbXdhbmdAcmVkaGF0LmNvbT4KLi4uCj4gICBjcmVhdGUgbW9kZSAx
MDA2NDQgZHJpdmVycy9uZXQvdGVhbS9Nb2R1bGUuc3ltdmVycwoKVGhpcyBwaWVjZSBpcyBub3Qg
Y29ycmVjdCwgSSB3aWxsIHNlbmQgYW4gdXBkYXRlZCBwYXRjaC4KCi0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQpBbGwgdGhlIGRhdGEgY29udGludW91c2x5IGdlbmVyYXRlZCBpbiB5b3VyIElUIGluZnJh
c3RydWN0dXJlIApjb250YWlucyBhIGRlZmluaXRpdmUgcmVjb3JkIG9mIGN1c3RvbWVycywgYXBw
bGljYXRpb24gcGVyZm9ybWFuY2UsIApzZWN1cml0eSB0aHJlYXRzLCBmcmF1ZHVsZW50IGFjdGl2
aXR5LCBhbmQgbW9yZS4gU3BsdW5rIHRha2VzIHRoaXMgCmRhdGEgYW5kIG1ha2VzIHNlbnNlIG9m
IGl0LiBJVCBzZW5zZS4gQW5kIGNvbW1vbiBzZW5zZS4KaHR0cDovL3Auc2YubmV0L3NmdS9zcGx1
bmstbm92ZDJkCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
CkUxMDAwLWRldmVsIG1haWxpbmcgbGlzdApFMTAwMC1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5u
ZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vZTEwMDAtZGV2
ZWwKVG8gbGVhcm4gbW9yZSBhYm91dCBJbnRlbCYjMTc0OyBFdGhlcm5ldCwgdmlzaXQgaHR0cDov
L2NvbW11bml0aWVzLmludGVsLmNvbS9jb21tdW5pdHkvd2lyZWQK
