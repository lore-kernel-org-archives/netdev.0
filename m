From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Wed, 20 Sep 2006 15:55:36 -0700
Message-ID: <20060920155536.5454f504@localhost.localdomain>
References: <20060918103705.GB1096@ms2.inr.ac.ru>
	<20060918.065655.128444024.davem@davemloft.net>
	<20060920154406.3c2c1721@localhost.localdomain>
	<20060920.154756.37589174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50844 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932444AbWITW4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 18:56:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060920.154756.37589174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Sep 2006 15:47:56 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 20 Sep 2006 15:44:06 -0700
> 
> > On Mon, 18 Sep 2006 06:56:55 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > Ok, I'll put this into net-2.6.19 for now.  Thanks.
> > 
> > Did you try this on a desktop system?  Something is wrong with net-2.6.19
> > basic web browsing seems slower.
> 
> It might be due to other changes, please verify that it's
> truly caused by Alexey's change by backing it out and
> retesting.
> 
> Note that I had to use an updated version of Alexey's change,
> which he sent me privately, because the first version didn't
> compile :)

It might be something else.. there are a lot of changes from 2.6.18 to net-2.6.19.



-- 
Stephen Hemminger <shemminger@osdl.org>
