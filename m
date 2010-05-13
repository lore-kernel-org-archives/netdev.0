From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Thu, 13 May 2010 12:40:08 -0400
Message-ID: <1273768808.6117.5.camel@bigi>
References: <20100511172412.76aff184@nehalam>
	 <1273684674.16074.0.camel@bigi> <20100512111706.616dc7cf@nehalam>
	 <1273691628.16074.15.camel@bigi> <20100512132042.3b38da18@nehalam>
	 <1273696903.16074.25.camel@bigi> <4BEBFAD4.1030608@trash.net>
	 <1273767626.6117.3.camel@bigi>  <20100513092643.6551cb48@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59300 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab0EMQkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:40:15 -0400
Received: by wyb32 with SMTP id 32so1047911wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 09:40:13 -0700 (PDT)
In-Reply-To: <20100513092643.6551cb48@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-13 at 09:26 -0700, Stephen Hemminger wrote:

> > 
> 
> And the kernel message needs to be fixed to prevent total
> log overload for the next poor sop who makes the same mistake.
> 
> Please accept the patch.

I have no problem with the patch. Dont think it needs to go to stable
but i'll let Dave call it.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

