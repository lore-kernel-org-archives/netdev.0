From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: remove c99ism
Date: Mon, 17 Jan 2005 13:40:53 -0800
Message-ID: <20050117134053.626cce63.davem@davemloft.net>
References: <20050115144010.33182075.akpm@osdl.org>
	<20050115232554.GS26856@postel.suug.ch>
	<20050115153202.2f7f81c6.akpm@osdl.org>
	<20050115234056.GT26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050115234056.GT26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Jan 2005 00:40:56 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Andrew Morton <20050115153202.2f7f81c6.akpm@osdl.org> 2005-01-15 15:32
> > An uglier but more efficient approach is to whack braces around the whole
> > thing.
> 
> Fine with me as well. The code isn't used that often and not deep in the
> calling stack which is why I preferred the cleaner way first.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
