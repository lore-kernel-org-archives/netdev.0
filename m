From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Mon, 30 Jan 2017 08:47:52 -0800
Message-ID: <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
 <38ccfaea-0a65-a6f3-c19a-e6f9c0d4ef76@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, Paul Durrant <paul.durrant@citrix.com>,
 Wei Liu <wei.liu2@citrix.com>, David Miller <davem@davemloft.net>,
 xen-devel <xen-devel@lists.xen.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 <linux-kernel@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <38ccfaea-0a65-a6f3-c19a-e6f9c0d4ef76@oracle.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

Ck9uIDAxLzI5LzIwMTcgMDM6MDkgUE0sIEJvcmlzIE9zdHJvdnNreSB3cm90ZToKPgo+IFRoZXJl
IGFyZSBjb3VwbGUgb2YgcHJvYmxlbXMgd2l0aCB0aGlzIHBhdGNoLgo+IDEuIFRoZSAnaWYnIGNs
YXVzZSBub3cgZXZhbHVhdGVzIHRvIHRydWUgb24gcHJldHR5IG11Y2ggZXZlcnkgY2FsbCB0byAK
PiB4ZW5uZXRfYWxsb2NfcnhfYnVmZmVycygpLgpUaGFua3MgZm9yIGNhdGNoaW5nIHRoaXMuIElu
IG15IHRlc3RpbmcgSSBkaWQgbm90IG5vdGljZSB0aGlzIC0gbW9zdGx5IApiZWNhdXNlIG9mIHRo
ZSBuYXR1cmUgb2YgdGhlIHdvcmtsb2FkIGluIG15IHRlc3RpbmcuCgo+IDIuIEl0IHRpY2tsZXMg
YSBsYXRlbnQgYnVnIGR1cmluZyByZXN1bWUgd2hlcmUgdGhlIHRpbWVyIHRyaWdnZXJzIAo+IGJl
Zm9yZSB3ZSByZS1jb25uZWN0LiBUaGUgdHJvdWJsZSBpcyB0aGF0IHdlIG5vdyB0cnkgdG8gZGVy
ZWZlcmVuY2UgCj4gcXVldWUtPnJ4LnNyaW5nIHdoaWNoIGlzIE5VTEwgc2luY2Ugd2UgZGlzY29u
bmVjdCBpbiAKPiBuZXRmcm9udF9yZXN1bWUoKS4gKEN1cmlvdXNseSwgSSBvbmx5IG9ic2VydmUg
aXQgd2l0aCAzMi1iaXQgZ3Vlc3RzKQpJIHRoaW5rIHdlIG1heSBoaXQgdGhpcyBidWcgYWZ0ZXIg
cmVtb3ZpbmcgdGhlIHRpbWVyIGFzIHdlbGwuIFdlIGNhbGwgClJJTkdfUFVTSF9SRVFVRVNUU19B
TkRfQ0hFQ0tfTk9USUZZIHNvb24gYWZ0ZXIsIHdoaWNoIGFsc28gZGVyZWZlcmVuY2UgCnF1ZXVl
LT5yeC5zcmluZy4KClRoYW5rcywKVmluZWV0aAoKCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxp
c3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
