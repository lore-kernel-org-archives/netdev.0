From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4 PKT_SCHED] Report qdisc parent to userspace
Date: Tue, 28 Sep 2004 20:56:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928205650.243d4e96.davem@davemloft.net>
References: <20040929000150.GA9113@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040929000150.GA9113@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 02:01:50 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Report parent classid of a qdisc back to userspace. Without this there
> is no way for userspace to see if the qdisc is attached to a class
> other than parsing all class trees of the link and check all tcm_info
> fields in the leaf classes.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
