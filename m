From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH 00/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 09:03:15 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711070856130.27362@netcore.fi>
References: <20071107.145550.50882731.yoshfuji@linux-ipv6.org>
 <OF6A8C8B34.85D1FAD8-ON8825738C.00215308-8825738C.00218D8F@us.ibm.com>
 <20071106.223705.246628214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org,
	Fred.L.Templin@boeing.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:60227 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103AbXKGHEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 02:04:06 -0500
In-Reply-To: <20071106.223705.246628214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Nov 2007, David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Tue, 6 Nov 2007 22:07:44 -0800
>
>>> I guess license is no longer required for implementers of ISATAP.
>>> Is it right, Fred?
>>>
>>> https://datatracker.ietf.org/ipr/550/
>>
>> Does this also allow license-free redistribution?
>>
>> I'm certainly no lawyer, but I don't see the point of
>> having a patent that doesn't restrict *something*. :-)

DavidS, the history here is that first the IPR holder did not grant 
license-free implementation.  After considerable time (and I suspect 
energy spent by Fred), the company was convinced that license-free 
implementation did not hurt their interests and they were willing to 
give it away on this specific instance.  I'm not sure if you should 
attribute to hidden agendas what you can explain by "doing the right 
thing" (granted, very few companies do this which may make it suspect, 
but still..).

> That is my interpretation as well.  It allows license free 
> implementation, but not distribution of said implementation.

This may be a fine point.  When submitting the IPR notice, the IPR 
holder is asked whether it can be implemented without a license.  No 
questions about redistribution are asked -- maybe nobody thought that 
asking that would be necessary if a positive answer is received on the 
first one.  I'd guess that the owner that grants license-free 
implementation would also be fine with license-free (re-)distribution.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
