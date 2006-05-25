From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Thu, 25 May 2006 23:17:16 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605252316250.28494@math.ut.ee>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
 <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:57289 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751092AbWEYURU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:17:20 -0400
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> On my home 6to4 gw, ipv6 routing seems to be broken and everything is sent 
>> to 6to4 tunnel (the default route). It worked with fine for a long time and 
>> with 2.6.17-rc2-g4d5c34ec and it's broken with vmlinuz-2.6.17-rc3-g3cd73eed 
>> and 2.6.17-rc4-g9be2f7c3 (yesterdays kernel).

So far I have narrowed it down to break between 2.6.16 (working) and 
2.6.17-rc1 (not working).

-- 
Meelis Roos (mroos@linux.ee)
