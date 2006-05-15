From: Meelis Roos <mroos@linux.ee>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Mon, 15 May 2006 22:28:48 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605152227290.8543@math.ut.ee>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee> <446765CC.8020500@trash.net>
 <Pine.SOC.4.61.0605152028420.9077@math.ut.ee> <4468CB51.4060707@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:21132 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751565AbWEOT2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 15:28:51 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4468CB51.4060707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> This should already be fixed in -rc4.
>>
>> Unfortunately it was still there with yesterdays rc4+git.
>
> I may have misinterpreted your report - are you running a 32bit or 64bit
> kernel?

32-bit kernel, this is a Motorola Powerstack II macine with 604e. PReP 
subarch, only buildable from the old ARCH=ppc code (not yet migrated to 
ARCH=powerpc).

-- 
Meelis Roos (mroos@linux.ee)
