From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (3/3) rtnetlink -- ASSERT_RTNL and BUG_TRAP
Date: Tue, 23 Sep 2003 04:02:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923040243.30a034a3.davem@redhat.com>
References: <20030922163946.5854bb8e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030922163946.5854bb8e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2003 16:39:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Change ASSERT_RTNL and BUG_TRAP
> 	- unlikely to occur
> 	- tag message as error
> 	- dump_stack in ASSERT_RTNL to aide finding code path
> 	- make all format's which a smart compiler can optimize

Looks good to me, applied thanks.
