From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] tcp: efficient port randomistion (rev 3)
Date: Mon, 20 Dec 2004 15:39:16 -0800
Message-ID: <20041220153916.6c00c114.davem@davemloft.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<20041202135252.04e64f51.davem@davemloft.net>
	<41B14E57.5080803@osdl.org>
	<200412060918.04441.michael.vittrup.larsen@ericsson.com>
	<20041206094234.34861c78@dxpl.pdx.osdl.net>
	<20041208235524.202ff3a1.davem@davemloft.net>
	<20041210170900.11d41d56.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041210170900.11d41d56.shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 17:09:00 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> okay, here is the revised version. Testing shows that it
> is more consistent, and just as fast as existing code,
> probably because of the getting rid of portalloc_lock and
> better distribution.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Queued up for 2.6.11, thanks Stephen.
