From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 16:16:28 -0400
Message-ID: <20060719161628.284b4c01@localhost.localdomain>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
	<20060719155204.0de8882b@localhost.localdomain>
	<20060719.130150.39158599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56012 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030270AbWGSUR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 16:17:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060719.130150.39158599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jul 2006 13:01:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 19 Jul 2006 15:52:04 -0400
> 
> > As a related note, I am looking into fixing inet hash tables to use RCU.
> 
> IBM had posted a patch a long time ago, which would be not
> so hard to munge into the current tree.  See if you can
> spot it in the archives :)

Ben posted a patch in March, and IBM did one a while ago.
I am looking at both.
