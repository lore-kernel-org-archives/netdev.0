From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RESEND PATCH 2.6 PKT_SCHED] Report qdisc parent to userspace
Date: Tue, 28 Sep 2004 14:19:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928141907.114e5da1.davem@davemloft.net>
References: <20040924123710.GB3944@postel.suug.ch>
	<20040924125240.GT31616@rei.reeler.org>
	<20040924140039.GA4079@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040924140039.GA4079@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 16:00:39 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> This patch should be better, sorry for the brain dead patch before.
> 
> Report parent classid of a qdisc back to userspace. Without this there
> is no way for userspace to see if the qdisc is attached to a class
> other than parsing all class trees of the link and check all tcm_info
> fields in the leaf classes.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This patch looks fine to me, applied.

Thanks Thomas.
