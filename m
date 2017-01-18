From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2 1/2] xen-netback: fix memory leaks on
	XenBus disconnect
Date: Wed, 18 Jan 2017 09:45:16 +0000
Message-ID: <20170118094516.GJ5089@citrix.com>
References: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
 <1484686178-76959-2-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: xen-devel@lists.xenproject.org, Paul.Durrant@citrix.com,
 wei.liu2@citrix.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Igor Druzhinin <igor.druzhinin@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1484686178-76959-2-git-send-email-igor.druzhinin@citrix.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gVHVlLCBKYW4gMTcsIDIwMTcgYXQgMDg6NDk6MzdQTSArMDAwMCwgSWdvciBEcnV6aGluaW4g
d3JvdGU6Cj4gRWxpbWluYXRlIG1lbW9yeSBsZWFrcyBpbnRyb2R1Y2VkIHNldmVyYWwgeWVhcnMg
YWdvIGJ5IGNsZWFuaW5nIHRoZQo+IHF1ZXVlIHJlc291cmNlcyB3aGljaCBhcmUgYWxsb2NhdGVk
IG9uIFhlbkJ1cyBjb25uZWN0aW9uIGV2ZW50LiBOYW1lbHksIHF1ZXVlCj4gc3RydWN0dXJlIGFy
cmF5IGFuZCBwYWdlcyB1c2VkIGZvciBJTyByaW5ncy4KPiAKPiBTaWduZWQtb2ZmLWJ5OiBJZ29y
IERydXpoaW5pbiA8aWdvci5kcnV6aGluaW5AY2l0cml4LmNvbT4KCkFja2VkLWJ5OiBXZWkgTGl1
IDx3ZWkubGl1MkBjaXRyaXguY29tPgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVu
Lm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
