From: Ariel Hendel <Ariel.Hendel@SUN.COM>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Thu, 20 Sep 2007 09:06:20 -0700
Message-ID: <46F29A7C.8040801@sun.com>
References: <20070918.151528.84360712.davem@davemloft.net>
 <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
 <46F1AEC7.8090604@hp.com> <20070919.165323.127197853.davem@davemloft.net>
Reply-To: Ariel.Hendel@SUN.COM
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: rick.jones2@hp.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, Greg.Onufer@SUN.COM, jeff@garzik.org,
	Matheos.Worku@SUN.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:37693 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802AbXITQp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 12:45:57 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id l8KG6cVU012263
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 16:06:38 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JOO00J01CC4YU00@mail-amer.sun.com>
 (original mail from Ariel.Hendel@Sun.COM) for netdev@vger.kernel.org; Thu,
 20 Sep 2007 10:06:38 -0600 (MDT)
In-reply-to: <20070919.165323.127197853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Dave for your preliminary posting of the driver.
I am copying Matheos Worku. Matheos is intimately familiar with 
the Neptune/NIU family of devices and their respective drivers.

Not only he can be a good reviewer, he can also clarify issues 
around naming and so on. I agree that Neptune is just an overused 
internal codename not worth propagating in the code.

Please feel free to add Matheos.Worku@Sun.COM to the reviewers list.

Ariel

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 19 Sep 2007 16:20:39 -0700
> 
> 
>>so why "niu?"  To what does niu translate anyway?
> 
> 
> Network Interface Unit.  This is what the Niagara-2 programmers manual
> refers to the chip as.
> 
> I try to name the files for most drivers I write as a 2 or 3 letter
> acronyms, it looks so much better than the usual verbose names.  It's
> very unix.
