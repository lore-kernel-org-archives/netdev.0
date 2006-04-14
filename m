From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] net: expose vlan structure to user space
Date: Fri, 14 Apr 2006 17:10:59 -0400
Message-ID: <44400FE3.9030507@roinet.com>
References: <4436BB69.3010205@roinet.com>	<443FA08A.8040900@roinet.com> <20060414.135556.91849056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:10684
	"HELO roinet.com") by vger.kernel.org with SMTP id S965166AbWDNVLA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 17:11:00 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.135556.91849056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: David Acker <dacker@roinet.com>
> Date: Fri, 14 Apr 2006 09:15:54 -0400
> 
> 
>>David S. Miller wrote:
>> > I think this really belongs in a portable header file
>> > in glibc somewhere.
>>
>>David, while I can try to work with the glibc folks, I don't understand 
>>how this patch would be different from what if_ether.h exposes to user 
>>space today.  Why is one appropriate and the other not?  I am not trying 
>>to be a pain; I am just trying to understand the rationale so that I can 
>>explain it to others.
> 
> 
> Doing stupid things in the past does not equate to being a reason
> to keep doing so in the future.
> 
> 

Understood.  I will see what I can do in glibc land instead.
-Ack

