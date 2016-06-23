From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Thu, 23 Jun 2016 13:14:07 +0800
Message-ID: <576B701F.2020105@redhat.com>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
	<20160617033218-mutt-send-email-mst@redhat.com>
	<20160622211620-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, brouer@redhat.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160622211620-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE25bm0MDbmnIgyM+aXpSAwMjoxOCwgTWljaGFlbCBTLiBUc2lya2luIHdyb3RlOgo+
IE9uIEZyaSwgSnVuIDE3LCAyMDE2IGF0IDAzOjQxOjIwQU0gKzAzMDAsIE1pY2hhZWwgUy4gVHNp
cmtpbiB3cm90ZToKPj4gPldvdWxkIGl0IGhlbHAgdG8gaGF2ZSBwdHJfcmluZ19yZXNpemUgdGhh
dCBnZXRzIGFuIGFycmF5IG9mCj4+ID5yaW5ncyBhbmQgcmVzaXplcyB0aGVtIGJvdGggdG8gc2Ft
ZSBsZW5ndGg/Cj4gT0ssIGhlcmUgaXQgaXMuIFVudGVzdGVkIHNvIGZhciwgYW5kIG5vIHNrYiB3
cmFwcGVyLgo+IFBscyBsZXQgbWUga25vdyB3aGV0aGVyIHRoaXMgaXMgd2hhdCB5b3UgaGFkIGlu
IG1pbmQuCgpFeGFjdGx5IHdoYXQgSSB3YW50LgoKVGhhbmtzCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApW
aXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
