From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: ipv6_skip_exthdr() may refer invalid memory area
Date: Fri, 20 Feb 2004 09:30:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220093027.2c03f48c.davem@redhat.com>
References: <200402200534.OAA04081@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200402200534.OAA04081@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 14:33:59 +0900 (JST)
Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:

> ipv6_skip_exthdr() refer invalid memory area in the case
> that packet includes Fragment Header.
> 
> please apply this patch.

Applied, thank you Yasuyuki-san.
