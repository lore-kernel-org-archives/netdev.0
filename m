From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH PKT_SCHED 0/6]: assorted fixes
Date: Thu, 13 Jan 2005 20:49:57 -0800
Message-ID: <20050113204957.0fd3a800.davem@davemloft.net>
References: <41E44926.5010701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41E44926.5010701@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Jan 2005 22:46:14 +0100
Patrick McHardy <kaber@trash.net> wrote:

> following are a couple of assorted fixes: a mem leak, locking bugs in two
> tc actions, your sch_api.c fix for holding the rtnl while loading modules
> ported to act_api.c, and a bug in tcf_exts that prevents using 
> actions/policers
> without a rate estimator.
> 
> You can pull all changes from bk://212.42.230.204/net-2.6-sched

Pulled, thanks a lot Patrick.
