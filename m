From: James Chapman <jchapman@katalix.com>
Subject: Re: Wired behaviour with IPv6 over PPP
Date: Fri, 23 May 2008 11:46:04 +0100
Message-ID: <4836A06C.2050301@katalix.com>
References: <48341C0B.7010003@interway.ch> <20080522014959.0f6191aa.akpm@linux-foundation.org> <48354318.60202@katalix.com> <4835C40B.60603@interway.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Matthias Cramer <matthias.cramer@interway.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:51115 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbYEWKqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 06:46:17 -0400
In-Reply-To: <4835C40B.60603@interway.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthias Cramer wrote:
> James Chapman wrote:
>> Did this work with previous kernel versions?
> 
> No, in my opinion it never worked. But I thought that pppd does it wrong
> because id never got an IPv6 address. But I had always forwarding
> enabled. Now in this case i started pppd without forwarding enabled and
> got an address.
> 
>> Does pppd log any errors?
> 
> No, no errors

Could you post a pppd debug log showing the ppp protocol exchange with 
the peer in the failing case? It might give some clues.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

