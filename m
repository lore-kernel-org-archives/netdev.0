From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] xen-netback: fix memory leaks on
 XenBus disconnect
Date: Wed, 18 Jan 2017 15:11:36 -0500 (EST)
Message-ID: <20170118.151136.1215012149312737268.davem@davemloft.net>
References: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: xen-devel@lists.xenproject.org, Paul.Durrant@citrix.com,
 wei.liu2@citrix.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: igor.druzhinin@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RnJvbTogSWdvciBEcnV6aGluaW4gPGlnb3IuZHJ1emhpbmluQGNpdHJpeC5jb20+CkRhdGU6IFR1
ZSwgMTcgSmFuIDIwMTcgMjA6NDk6MzYgKzAwMDAKCj4gSnVzdCBzcGxpdCB0aGUgaW5pdGlhbCBw
YXRjaCBpbiB0d28gYXMgcHJvcG9zZWQgYnkgV2VpLgo+IAo+IFNpbmNlIHRoZSBhcHByb2FjaCBm
b3IgbG9ja2luZyBuZXRkZXYgc3RhdGlzdGljcyBpcyBpbmNvbnNpc3RlbnQgKHRlbmRzIG5vdAo+
IHRvIGhhdmUgYW55IGxvY2tpbmcgYXQgYWxsKSBhY2Nyb3NzIHRoZSBrZXJuZWwgd2UnZCBiZXR0
ZXIgdG8gcmVseSBvbiBvdXIKPiBpbnRlcm5hbCBsb2NrIGZvciB0aGlzIHB1cnBvc2UuCgpTZXJp
ZXMgYXBwbGllZCwgdGhhbmtzLgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9y
ZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
