From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC ] [2 of 4] IEEE802.11 Regulatory/Geographical Support for
 drivers - database
Date: Sun, 11 Jun 2006 10:59:55 -0500
Message-ID: <448C3DFB.2000305@lwfinger.net>
References: <4482110B.4080404@lwfinger.net> <20060611094236.GE24167@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:5305 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750999AbWFKP77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 11:59:59 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060611094236.GE24167@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uli,

Thanks for the comments.

Ulrich Kunitz wrote:

> two minor comments.
> 
> 1. I appreciate that you are keeping everything in 80 character
>    lines. So I believe the one line extending 80 characters is an
>    oversight.

I have tried, but will watch that more carefully.

> 
> 2. Could you just add a simple explanation for the pow column for
>    the uninformed reader?

It was described in the initial text material that was not sent out. I have duplicated that info at 
the beginning of each type of group description, and have added it to the header on the debug output 
as follows:

AT, HR, CY, CZ, DK, EE, EU, FI, FR, GF, DE, VA, HU, IE, IT, LV, LT, LU, MK, MT
NL, PL, RE, SI, SE, GB

Indoor Group 1 with 18 channels in 5 GHz bands

   Chn  Freq Pow(dBm)   Flags
    36  5180    23      PASSIVE   H_RULES
    40  5200    23      PASSIVE   H_RULES
    44  5220    23      PASSIVE   H_RULES
    48  5240    23      PASSIVE   H_RULES
    52  5260    23      PASSIVE   H_RULES


Larry
