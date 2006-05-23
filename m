From: Simon Oosthoek <wmc_simon@fastmail.fm>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 19:43:02 +0200
Message-ID: <447349A6.50105@fastmail.fm>
References: <44731733.7000204@ti-wmc.nl> <20060523094324.11926fcc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpq3.tilbu1.nb.home.nl ([213.51.146.202]:20649 "EHLO
	smtpq3.tilbu1.nb.home.nl") by vger.kernel.org with ESMTP
	id S932093AbWEWRms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 13:42:48 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060523094324.11926fcc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 23 May 2006 16:07:47 +0200
> Herman Elfrink <herman.elfrink@ti-wmc.nl> wrote:
> 
>>  
>> FLAME stands for "Forwarding Layer for Meshing"
>>
> 
> Didn't you just reinvent 802.1d bridging? and/or WDS?

I wouldn't say "reinvent", but the difference is small but significant. 
FLAME could be seen as ad hoc WDS, I think. It doesn't need to know 
about the other "base-stations", which I think WDS does.

> As far as the Ethernet protocol field. Getting a real assigned number
> would have to come out of the IEEE 802. 
> 
> You would need
> 	http://standards.ieee.org/regauth/ethertype/forms/index.html
> 
> It is cheaper (free vs $2500) to get a LLC sap assigned, but then
> you would have to change the protocol.
> 	http://standards.ieee.org/regauth/llc/index.html

Wow, thanks, $2500 is a bit steep for a useful experiment ;-)
The free option could be interesting though...

Cheers

Simon

