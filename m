From: Daniel Drake <ddrake@brontes3d.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 10:56:17 -0500
Message-ID: <1164815777.3331.5.camel@systems03.lan.brontes3d.com>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	 <200611282145.08423.mb@bu3sch.de>
	 <40f31dec0611290555t42d28247x7f163527fac438c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:61322 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S967444AbWK2P4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 10:56:24 -0500
To: Nick Kossifidis <mickflemm@gmail.com>
In-Reply-To: <40f31dec0611290555t42d28247x7f163527fac438c1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-29 at 15:55 +0200, Nick Kossifidis wrote:
> I 've already ported ar5k to linux and it works with madwifi versions
> before the bsd-head merge, you can see more infos here ->
> http://madwifi.org/wiki/OpenHAL
> 
> If i can help in any way feel free to mail ;-)

Thanks, I'm trying it out to see whether it works on my hardware. I
compiled and loaded everything OK, ath0 appears, but it doesn't seem to
be working.

I'm using these commands:

ifconfig ath0 up
iwlist ath0 scan

Should that produce scan results, or do I need to use some weird tools
to do that? (this is my first interaction with the madwifi-old driver)

Currently it pauses for a while and then doesn't present any results.

Thanks!

-- 
Daniel Drake
Brontes Technologies, A 3M Company

