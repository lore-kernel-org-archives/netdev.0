From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Remove useless line in cbq_dump_class
Date: Tue, 5 Oct 2004 13:37:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005133754.154cf9ee.davem@davemloft.net>
References: <20041003221452.GL14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041003221452.GL14344@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 00:14:52 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Remove useless line in cbq_dump_class probably introduced by
> copy&paste from cbq_dump.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to both 2.4.x and 2.6.x, thanks Thomas.

If you could check quickly whether a 2.6.x patch you post
is a relevant bug fix for 2.4.x, that would help me out
a lot in processing your patches efficiently.

Thanks.
