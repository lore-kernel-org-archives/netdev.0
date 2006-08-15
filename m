From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-d80211: Init, shutdown and restart fixes
Date: Tue, 15 Aug 2006 16:00:39 -0500
Message-ID: <44E235F7.6020104@lwfinger.net>
References: <200608142132.25398.mb@bu3sch.de> <44E1E6E6.9000804@lwfinger.net> <200608151730.26255.mb@bu3sch.de> <20060815154440.GD28544@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:55729 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750708AbWHOVAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 17:00:55 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060815154440.GD28544@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> 
> Actually, this leads to a bigger question.  I noticed Michael
> pleading his support dilemma w.r.t. supporting both wireless-2.6
> and wirless-dev.  I'm sure he now regrets the "stunt" of trying to
> support both at the same time... :-)
> 
> Anyway, it would seem like many of these fixes would be readily ported
> between the trees.  It seems like we need someone to take-on this
> (admittedly thankless) maintainence task from now until the new stack
> merges into wireless-2.6.
> 
> Larry, you seem like a great candidate for this role.  Are you
> interested?  If not, is there someone else in the bcm43xx camp that
> would oblige us?
> 
> Thanks in advance!
> 
> John
> 
> P.S.  FWIW, I definitely thank Michael for his work supporting both
> stack to date.  I think the dscape stack would be much farther behind
> w/o the users enabled by the bcm43xx-dscape driver.

I too thank Michael for all his work. I am willing to take the bcm43xx-dscape 
changes and port them to softmac. My understanding of kernel coding is not 
sufficient for me to do many of these things from scratch, but if Michael is 
willing to answer my questions, I'll do my best.

Larry
