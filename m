From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] sctp/socket: fix printk arg. type
Date: Thu, 18 Nov 2004 13:52:22 -0800
Message-ID: <20041118135222.67651b21.davem@davemloft.net>
References: <419906AA.8010705@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, sri@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <419906AA.8010705@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Nov 2004 11:42:34 -0800
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> fix printk argument type warning:
> net/sctp/socket.c:2672: warning: format argument is not a pointer (arg 5)

Applied, thanks Randy.
