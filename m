From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Setting alternate MAC addresses on e1000
Date: Tue, 08 Apr 2008 19:45:25 +0200
Message-ID: <47FBAF35.5030004@aei.mpg.de>
References: <47F2358A.8080505@aei.mpg.de> <20080408170217.GA26591@gospo.usersys.redhat.com> <47FBAAAF.9060206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bill.hayes@hp.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:47657 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961AbYDHRpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 13:45:36 -0400
In-Reply-To: <47FBAAAF.9060206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Kok, Auke schrieb:
>> Bill posted a patch for this a while back (but it was not accepted since
>> support for that hardware is offically moving to e1000e).  This may be
>> what you want....
> 
> yeah I thought of that as well and after digging through the documentation I don't
> think this will work for 82573's - it seems that only 82571 hardware supports this
> feature, which is not what Carsten needs.
> 
> as stated above, the alternate eeprom layout of the 82573 seems to also indicate that.

Thanks for not forgetting me :)

I wasn't able to reply yet because I'm buried in work, but the initial 
tip, to just use a different ID for the second device worked already. 
Though I don't use the alternate MAC possibility, I can change the MAC 
address easily - and already did that on ~280 nodes on Sunday.

So, I would say, please consider my problem solved.

Thanks to all of you who replied and the rest for the thoughts and the 
software!

Cheers

Carsten
