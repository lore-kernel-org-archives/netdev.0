From: "Yuriy N. Shkandybin" <jura@netams.com>
Subject: Re: + ppp_generic-fix-lockdep-warning.patch added to -mm tree
Date: Wed, 11 Apr 2007 12:52:28 +0400
Message-ID: <028701c77c16$bcd68a90$0202fea9@Jura>
References: <200703282353.l2SNr2iL023119@shell0.pdx.osdl.net><01ef01c77bfe$4cdfe640$0202fea9@Jura> <20070411000932.1f00f395.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <jarkao2@o2.pl>, <paulus@samba.org>, <netdev@vger.kernel.org>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.netams.com ([212.192.245.10]:36687 "EHLO mail.netams.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbXDKIyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 04:54:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> (added netdev)
>
> On Wed, 11 Apr 2007 09:57:33 +0400 "Yuriy N. Shkandybin" <jura@netams.com> 
> wrote:
>
>> I've tested  2.6.21-rc6-mm1
>> Linux vpn1 2.6.21-rc6-mm1 #4 SMP Wed Apr 11 03:34:26 MSD 2007 x86_64
>> Intel(R) Pentium(R) D CPU 2.80GHz GenuineIntel GNU/Linux
>>
>> warn appeares upon first pppoe connection to rp-pppoe server in kernel 
>> mode
>>
>
> Thanks.  So you're saying that
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc6/2.6.21-rc6-mm1/broken-out/ppp_generic-fix-lockdep-warning.patch
> did not fix anything?
As i understand this patch already in -mm tree, so I've booted into last mm 
kernel and received this locked warning.
Or i've mistaked and should apply this patch manually?
>
> 

