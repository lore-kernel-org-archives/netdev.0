From: Hans de Goede <j.w.r.degoede@hhs.nl>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 11:45:07 +0200
Message-ID: <48B52223.5010606@hhs.nl>
References: <48B46E89.4030104@hhs.nl>	<48B47543.8080701@cosmosbay.com>	<48B51AE9.5080709@hhs.nl> <20080827.020556.90577040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.versatel.nl ([62.58.50.88]:53941 "EHLO smtp1.versatel.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243AbYH0Jd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:33:58 -0400
In-Reply-To: <20080827.020556.90577040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Hans de Goede <j.w.r.degoede@hhs.nl>
> Date: Wed, 27 Aug 2008 11:14:17 +0200
> 
>> Now you can wing it any way you want, but this is a serious
>> regression. I don't want to go to lkml and start shouting regression
>> REGRESSION regression, but given the treating and enormous amount of
>> help I've received sofar (and remember I'm only the messenger I
>> didn't write nor use gkrellmd) I'm tending towards starting shouting
>> regression on lkml, as atleast there this seems to get some
>> attention.
> 
> Last time I checked, one doesn't throw threats at people when they
> want help from them.
> 
> Please don't do that to us.
> 

I'm sorry, but I didn't have the feeling I had many options left. I've reported 
a serious performance regression and all the answer I've been getting sofar is: 
"well if that is slow don't do that you silly" which is anything but a 
satisfying answer.

Anyways as said I'm just the man in the middle, people are hitting this 
performance regression in real life scenarios. I've done my best to make this 
regression clear and known to you, and now I'm done with this thread, please 
remove me from the CC for further replies.

Regards,

Hans
