From: Russell Stuart <russell@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 27 Jun 2006 16:19:45 +1000
Message-ID: <44A0CE01.4010109@stuart.id.au>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <449C06E3.3090406@trash.net> <1151282720.4210.46.camel@ras.pc.brisbane.lube> <449FC0AF.1050904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:31462 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1030667AbWF0GU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 02:20:56 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <449FC0AF.1050904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/06/2006 9:10 PM, Patrick McHardy wrote:
>>5.  We still did have to modify the kernel for ATM.  That was
>>    because of its rather unusual characteristics.  However,
>>    it you look at the size of modifications made to the kernel
>>    verses the size made to the user space tool, (37 lines
>>    versus 303 lines,) the bulk of the work was does in user
>>    space.
> 
> I'm sorry, but arguing that a limited special case solution is
> better because it needs slightly less code is just not reasonable.

Without seeing your actual proposal it is difficult to
judge whether this is a reasonable trade-off or not.
Hopefully we will see your code soon.  Do you have any
idea when?
