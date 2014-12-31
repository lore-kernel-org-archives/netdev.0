From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] l2tp : multicast notification to the
 registered listeners
Date: Wed, 31 Dec 2014 14:17:31 -0500 (EST)
Message-ID: <20141231.141731.1681406451412491811.davem@davemloft.net>
References: <20141227101239.3ea24d70@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, g.nault-pHk1y4uTXVDytLWWfqlThQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141227101239.3ea24d70@urahara>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Date: Sat, 27 Dec 2014 10:12:39 -0800

> From: Bill Hong <bhong-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
> 
> Previously l2tp module did not provide any means for the user space to
> get notified when tunnels/sessions are added/modified/deleted.
> This change contains the following
> - create a multicast group for the listeners to register.
> - notify the registered listeners when the tunnels/sessions are
>   created/modified/deleted.
> 
> Signed-off-by: Bill Hong <bhong-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
> Reviewed-by: Sven-Thorsten Dietrich <sven-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>

Applied.
