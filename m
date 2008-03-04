From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [patch 11/11][NETNS][IPV6] rt6_stats - make the stats per network
 namespace
Date: Tue, 04 Mar 2008 15:59:58 +0100
Message-ID: <47CD63EE.8090204@bull.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>	<20080302094243.621444844@mai.toulouse-stg.fr.ibm.com> <20080303.233430.199177100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42739 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193AbYCDO7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 09:59:50 -0500
In-Reply-To: <20080303.233430.199177100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Sun, 02 Mar 2008 10:37:31 +0100
> 
>> The rt6_stats is now per namespace with this patch. It is
>> allocated when a network namespace is created and freed
>> when the network namespace exits and references are relative
>> to the network namespace.
>>
>> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> Also applied, thanks a lot guys!

Dave,

I can't see the patches in net-2.6.26 tree. Have you been forced
to revert them because they conflict with Yoshifuji patchset?
or am I too impatient? :)

Anyway, if you want us to resend the patchset refreshed for the latest 
net-2.6.26 don't hesitate to ask.

Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
