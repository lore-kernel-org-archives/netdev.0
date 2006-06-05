From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP Westwood Patch
Date: Mon, 5 Jun 2006 09:32:40 -0700
Message-ID: <20060605093240.5d68e117@dxpl.pdx.osdl.net>
References: <20060524182006.32fd1fcd@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Saverio Mascolo <saverio.mascolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25012 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750710AbWFEQch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 12:32:37 -0400
To: Luca De Cicco <ldecicco@gmail.com>
In-Reply-To: <20060524182006.32fd1fcd@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006 18:20:06 +0200
Luca De Cicco <ldecicco@gmail.com> wrote:

> Hi there to the list.
> 
> I'm Luca De Cicco a PhD student working on TCP Westwood+ at Politecnico
> di Bari.
> 
> I have attached a patch (it applies to 2.6.16.18 but it has been also
> tested on 2.6.15 too) for the TCP Westwood+ congestion control
> algorithm which fixes a bug and adds some new features/improvements:
> 
> o BUGFIX. The first sample was wrong
> 
> o RTT_min is updated each time a timeout event occurs (in order to
>   cope with hard handovers in wireless scenarios)
> 
> o The bandwidth estimate filter is now initialized with the first
> bandwidth sample in order to have better performances in the case of
> small file transfers.
> 
> Best regards,
> 
> Luca De Cicco
> Politecnico di Bari

Are you going  to split this up, or do you want me to do it?
You probably are busy with school work.
