From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.5.69] IPV4/6 inetsw using RCU
Date: Fri, 9 May 2003 07:49:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509054912.GL15829@Wotan.suse.de>
References: <20030508153307.73d16f5e.shemminger@osdl.org> <20030508.154320.128592193.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030508.154320.128592193.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 08, 2003 at 03:43:20PM -0700, David S. Miller wrote:
>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Thu, 8 May 2003 15:33:07 -0700
> 
>    This is a revised version of the earlier brlock removal patch, and
>    addresses all comments received so far. It is stable and works
>    reliably, but Dave, you may want to wait for any additional
>    comments before applying.
> 
> Okie dokie.  The patch looks fine to me.  Just let me know when
> it's ready to go in.

FWIW it looks good to me too.

-Andi
