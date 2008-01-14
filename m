From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 09:58:50 -0600
Message-ID: <478B86BA.1050706@nortel.com>
References: <478654C3.60806@nortel.com> <20080110.172049.118174993.davem@davemloft.net> <4787844E.4020107@nortel.com> <20080111.175310.212714342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:38197 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbYANP7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 10:59:03 -0500
In-Reply-To: <20080111.175310.212714342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Fri, 11 Jan 2008 08:59:26 -0600

>>I'd love to work on newer kernels, but we have a commitment to our 
>>customers to support multiple releases for a significant amount of time.

> And by asking here for people to dig into it for you, you are asking
> people for free help providing that support.

I'm not asking people to spend significant amounts of time...more like 
if anyone has any ideas "off the top of their heads".

> That's why there is such negative backlash to asking questions about
> such ancient kernel here, you're asking us to do your work, for free.

I hadn't realized that you felt this strongly about asking questions 
regarding old kernels.

How close to bleeding edge do we need to be for it to be considered 
acceptable to ask questions on netdev?

Given that the embedded space tends to be perpetually stuck on older 
kernels (our "current" release is based on 2.6.14) do you have any 
suggestion on how we can obtain information that would be available on 
netdev if we were using newer kernels?

Chris
