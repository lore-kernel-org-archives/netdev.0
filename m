From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] Use dev_get_flags() while building inet6 ifinfo
 message
Date: Mon, 14 Mar 2005 21:21:43 -0800
Message-ID: <20050314212143.4fed451e.davem@davemloft.net>
References: <20050315001417.GB3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050315001417.GB3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 01:14:17 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Use dev_get_flags() in inet6_fill_ifinfo() to fetch interface flags
> to ensure correctly reporting IFF_PROMISC and IFF_ALLMULTI flags.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
