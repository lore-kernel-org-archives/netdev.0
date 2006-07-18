From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 18 Jul 2006 09:35:10 -0400
Message-ID: <1153229710.5283.103.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <1151158431.6716.95.camel@jzny2>
	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:10765 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S932202AbWGRNhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 09:37:37 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1153188409.13145.5.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell,
I apologize i havent followed the latest discussion to the detail.
My understanding of Patricks work was it solved the ATM problem as well.
I think he is busy somewhere - lets give him an opportunity to respond
and i will try to catchup with the thread as well.

cheers,
jamal

On Tue, 2006-18-07 at 12:06 +1000, Russell Stuart wrote:
> On Sat, 2006-06-24 at 10:13 -0400, jamal wrote:
> > And yes, I was arguing that the tc scheme you describe would not be so
> > bad either if the cost of making a generic change is expensive.
> <snip>
> > Patrick seems to have a simple way to compensate generically for link
> > layer fragmentation, so i will not argue the practically; hopefully that
> > settles it? ;->
> 
> Things seem to have died down.  Patrick's patch seemed 
> unrelated to ATM to me.  I did put up another suggestion, 
> but I don't think anybody was too impressed with the 
> idea.  So that leave the current ATM patch as the only 
> one we have on the table that addresses the ATM issue.
> 
> Since you don't think it is "too bad", can we proceed 
> with it?
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

