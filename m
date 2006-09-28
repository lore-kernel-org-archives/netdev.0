From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 12:04:16 -0500
Message-ID: <451C0090.10109@lwfinger.net>
References: <200609271726.34305.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain> <451BE74F.3010908@lwfinger.net> <200609281135.24720.flamingice@sourmilk.net> <451BEFB8.8000402@lwfinger.net> <20060928163135.GH8121@knob.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Michael Buesch <mb@bu3sch.de>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:37525 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751942AbWI1REn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:04:43 -0400
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20060928163135.GH8121@knob.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> On Thu, Sep 28, 2006 at 10:52:24AM -0500, Larry Finger wrote:
>> I had very good luck with my first AP, a Linksys WRT54G V1, that I
>> bought a second when the power supply failed in the first. Little did
>> I know that a VxWorks license costs less than the extra memory needed
>> to run Linux. Or was it to defeat the open-source alternatives for the
>> AP?
> 
> last I checked, linksys (cisco?) still sells the linux-compatible
> version as the WRT54GL. <- note the extra 'L'.

I know, but have decided to stay with V5 (and bitch a lot) as others are likely to suffer from the 
same problems as I do. As many of them would never try alternate firmware, we need to provide the 
workarounds. If I'm using one of the brain-dead APs, I get the symptoms first hand and can tell when 
they are fixed.

Larry
