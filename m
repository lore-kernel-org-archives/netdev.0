From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: Use GFP_ATOMIC to allocate
	hash
Date: Thu, 02 Mar 2017 14:43:35 -0800 (PST)
Message-ID: <20170302.144335.2173019354901099768.davem@davemloft.net>
References: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, paul.durrant@citrix.com, wei.liu2@citrix.com,
 xen-devel@lists.xenproject.org
To: anoob.soman@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
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

RnJvbTogQW5vb2IgU29tYW4gPGFub29iLnNvbWFuQGNpdHJpeC5jb20+CkRhdGU6IFRodSwgMiBN
YXIgMjAxNyAxMDo1MDoyMCArMDAwMAoKPiBBbGxvY2F0aW9uIG9mIG5ld19oYXNoLCBpbnNpZGUg
eGVudmlmX25ld19oYXNoKCksIGFsd2F5cyBoYXBwZW4KPiBpbiBzb2Z0aXJxIGNvbnRleHQsIHNv
IHVzZSBHRlBfQVRPTUlDIGluc3RlYWQgb2YgR0ZQX0tFUk5FTCBmb3IgbmV3Cj4gaGFzaCBhbGxv
Y2F0aW9uLgo+IAo+IFNpZ25lZC1vZmYtYnk6IEFub29iIFNvbWFuIDxhbm9vYi5zb21hbkBjaXRy
aXguY29tPgoKQXBwbGllZC4KCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbi5vcmcK
aHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
