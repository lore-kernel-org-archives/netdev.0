From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Wed, 27 Sep 2006 19:43:28 -0500
Message-ID: <451B1AB0.9020302@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <451AA446.7060009@lwfinger.net> <200609271950.47430.mb@bu3sch.de> <1159395803.18293.72.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	Christian <email@christianhoffmann.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:12980 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1031088AbWI1Anu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 20:43:50 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1159395803.18293.72.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
>> 
> I won't try some random other git tree to test things, it's simply not
> feasible for me and we need something we can give to distros to backport
> so they have something remotely stable (I'm thinking for example about
> the upcoming ubuntu edgy which is coming out soon an a 2.6.17 base).

I don't know what your problem is! Despite your negative attitude, I have tried to accommodate you, 
but obviously you do not appreciate my efforts. My big patch for 2.6.18 concentrated on bcm43xx. Yes 
there were changes in softmac, but they had no major effect until Michael's fix of the race condition.

The bottom line is that I have had it with you! You had best go back to some mainline kernel as you 
will get no further help from me. There are lots of folks that need help _AND_ are appreciative of 
that help. My time will be spent on them.

Larry
