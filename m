From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] Doc: Fix missing whitespaces in RCU documentation.
Date: Sun, 29 Mar 2009 15:48:24 -0700
Message-ID: <20090329224824.GG11362@linux.vnet.ibm.com>
References: <20090329215103.27553.29216.stgit@localhost.localdomain> <20090329215247.27553.67635.stgit@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60718 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909AbZC2Ws1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2009 18:48:27 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2TMjDt2007910
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:45:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TMmPUs188150
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:48:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TMmO8Q026704
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:48:25 -0400
Content-Disposition: inline
In-Reply-To: <20090329215247.27553.67635.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 29, 2009 at 11:52:47PM +0200, Jesper Dangaard Brouer wrote:
> Trivial fix while reading through the RCU docs.
> 
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

I could have sworn that this was somewhere in the process, but cannot
find it.  So...

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  Documentation/RCU/rcu.txt |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/RCU/rcu.txt b/Documentation/RCU/rcu.txt
> index 95821a2..7aa2002 100644
> --- a/Documentation/RCU/rcu.txt
> +++ b/Documentation/RCU/rcu.txt
> @@ -81,7 +81,7 @@ o	I hear that RCU needs work in order to support realtime kernels?
>  	This work is largely completed.  Realtime-friendly RCU can be
>  	enabled via the CONFIG_PREEMPT_RCU kernel configuration parameter.
>  	However, work is in progress for enabling priority boosting of
> -	preempted RCU read-side critical sections.This is needed if you
> +	preempted RCU read-side critical sections.  This is needed if you
>  	have CPU-bound realtime threads.
> 
>  o	Where can I find more information on RCU?
> 
