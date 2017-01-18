From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Wed, 18 Jan 2017 12:24:53 -0800
Message-ID: <60561329-4308-895a-5958-558a3c8322f0@amazon.com>
References: <1484330100-3960-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <ee87b2e4-de8c-7b9b-c4e5-854ffab2e554@suse.com>
 <79c6ecce-bfcb-ebaa-afd2-05c1d86004d7@amazon.com>
 <20170118.151000.1216322099401442834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: jgross@suse.com, netdev@vger.kernel.org, kamatam@amazon.com,
 linux-kernel@vger.kernel.org, aliguori@amazon.com,
 xen-devel@lists.xenproject.org, boris.ostrovsky@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170118.151000.1216322099401442834.davem@davemloft.net>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

Ck9uIDAxLzE4LzIwMTcgMTI6MTAgUE0sIERhdmlkIE1pbGxlciB3cm90ZToKPiBUaGlzIHYyIG5l
dmVyIG1hZGUgaXQgaW50byBwYXRjaHdvcmsuICBJIGRvbid0IGtub3cgd2h5LCBzbyBwbGVhc2Ug
cmVzZW5kIGl0IHRvCj4gbmV0ZGV2IHdpdGggdGhlIGFjY3VtdWxhdGVkIHJldmlld2VkLWJ5IGV0
Yy4gdGFncyBhZGRlZC4KPgo+IFRoYW5rcy4KU29ycnkgYWJvdXQgdGhhdC4gV2lsbCByZXNlbmQg
YXMgYSBzZXBhcmF0ZSB0aHJlYWQgcmlnaHQgYXdheS4KClRoYW5rcwoKCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QK
WGVuLWRldmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
