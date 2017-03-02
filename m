From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: Use GFP_ATOMIC to allocate
	hash
Date: Thu, 2 Mar 2017 10:52:26 +0000
Message-ID: <20170302105226.za6oprdm67twsaen@citrix.com>
References: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, paul.durrant@citrix.com, wei.liu2@citrix.com,
 xen-devel@lists.xenproject.org
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gVGh1LCBNYXIgMDIsIDIwMTcgYXQgMTA6NTA6MjBBTSArMDAwMCwgQW5vb2IgU29tYW4gd3Jv
dGU6Cj4gQWxsb2NhdGlvbiBvZiBuZXdfaGFzaCwgaW5zaWRlIHhlbnZpZl9uZXdfaGFzaCgpLCBh
bHdheXMgaGFwcGVuCj4gaW4gc29mdGlycSBjb250ZXh0LCBzbyB1c2UgR0ZQX0FUT01JQyBpbnN0
ZWFkIG9mIEdGUF9LRVJORUwgZm9yIG5ldwo+IGhhc2ggYWxsb2NhdGlvbi4KPiAKPiBTaWduZWQt
b2ZmLWJ5OiBBbm9vYiBTb21hbiA8YW5vb2Iuc29tYW5AY2l0cml4LmNvbT4KCkFja2VkLWJ5OiBX
ZWkgTGl1IDx3ZWkubGl1MkBjaXRyaXguY29tPgoKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlz
dHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
