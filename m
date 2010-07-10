From: Kulikov Vasiliy <segooon@gmail.com>
Subject: Re: [PATCH] atmel: unregister_netdev() on error
Date: Sat, 10 Jul 2010 20:38:53 +0400
Message-ID: <20100710163853.GA4695@albatros>
References: <1278767508-10164-1-git-send-email-segooon@gmail.com>
 <20100710141204.GY19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	Simon Kelley <simon@thekelleys.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50496 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab0GJQja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 12:39:30 -0400
Content-Disposition: inline
In-Reply-To: <20100710141204.GY19184@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 16:12 +0200, Dan Carpenter wrote:
> > +err_out_unreg:
> > +	unregister_netdev(dev);
> 	^^^^^^^^^^^^^^^^^^^^^^
> > +
> 
> What the pants?  :P
Hmm, I've slightly misunderstood the code, sorry.

Thanks, Dan.
