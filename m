From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: B43 randomly and silently dropping connections...
Date: Tue, 14 Oct 2008 10:15:18 -0400
Message-ID: <20081014141517.GB3349@tuxdriver.com>
References: <200810131939.20891.mcbrides9@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jerry McBride <mcbrides9@comcast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39777 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbYJNOSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 10:18:02 -0400
Content-Disposition: inline
In-Reply-To: <200810131939.20891.mcbrides9@comcast.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You might try linux-wireless@vger.kernel.org for starters...

On Mon, Oct 13, 2008 at 07:39:20PM -0400, Jerry McBride wrote:
> 
> The story is...
> 
> I've moved from 2.6.25.x using BCM43XX with a Broadcom 4306 (rev3) 802.11 
> chipset to 2.6.26.6 using the B43 and appropriate firmware. This on a COMPAQ 
> Presario R3000 P4 and  a gig of memory and ATI graphics.
> 
> I followed the install (upgrade) directions at linuxwireless.org. Piece of 
> cake! However... I find that I've gone from "bulletproof" BCM43XX wifi 
> connections to "bullethole" connections with B43.  
> 
> Under the old BCM43XX the handshake and connections were flawless and 
> unfaltering. Now with the new B43, handshakes with AP's are perfect, but the 
> connections randomly and silently fail. There are no debug messages, no 
> complaints what-so-ever in /var/log/messages... 
> 
> To gt wireless back, I have to reinitialize the connection. I've gotten so 
> good at it, that I can recite by heart the appropriate commands...
> 
> It's killling me! I've got to get this ironed out... it's not just my laptop, 
> it's happening quite regularly with people I know with similar chips and 
> laptops.
> 
> Trying 2.6.27-rc's and now 2.6.27 and the situation is no better.
> 
> So I ask... Who is the B43/B43LEGACY maintainer and would you be interested in 
> debugging this mess? I'll bend over backward to help you... Email me 
> direct... I'm very willing.
> 
> SHORT STORY:
> -- Kernel 2.6.25.x with BCM43XX, firmware 4.80.53.0.. just perfect.
> 
> -- Kernels 2.6.26 or higher with B43 and firware 4.150.10.5 good negotiations, 
> but fragile connections that drop randomly and without complaint. B43LEGACY 
> does nothing.
> 
> Any help would be appreciated. I'd really like to get this ironed out. I 
> highly desire to use current kernels.
> 
> Feel free to email me direct.
> 
> -- 
> 
> *****************************************************************************
>                                        
>                              From the desk of:
>                              Jerome D. McBride
>                                        
>    19:17:28 up 15 days, 23:35,  5 users,  load average: 0.33, 0.11, 0.03
>  
> *****************************************************************************
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
