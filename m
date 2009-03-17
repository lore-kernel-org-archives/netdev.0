From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Tue, 17 Mar 2009 21:18:38 +0100
Message-ID: <49C0059E.5050405@krogh.cc>
References: <20090313.161217.52045656.davem@davemloft.net>	<8799.1236986836@death.nxdomain.ibm.com>	<49BEB7DE.9000201@krogh.cc> <20090316.133559.173588446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@redhat.com, aowi@novozymes.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:45581 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111AbZCQUSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 16:18:48 -0400
In-Reply-To: <20090316.133559.173588446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Mon, 16 Mar 2009 21:34:38 +0100
> 
>> Jay Vosburgh wrote:
>>> 	The above fragment isn't needed for mainline, only for -stable.
>>>
>> Did you sent it off to the stable kernel maintainers?
> 
> The fix has to go into Linus's tree first.
> 
> I haven't integrated Jay's changes yet.

Excellent. I was just trying to make sure that it wasn't lost somewhere 
in the process.

-- 
Jesper
