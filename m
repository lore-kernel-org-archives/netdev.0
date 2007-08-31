From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 13:33:04 +0400
Message-ID: <46D7E050.1030303@bigtelecom.ru>
References: <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:34233 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673AbXHaJdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:33:06 -0400
In-Reply-To: <20070831090509.GC1772@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> i not have testing mashine.
>> we have 2 mashine and dynamic routing. if 1 mashine down - all traffic 
>> go to second mashine.
>> I can test is on this mashines but i need that testing mashine will 
>> reboot on kernel panic (sysctl message). No freezes =)
>>
>> Ok. i try 2.6.23-rc4.
>>     
>
> ...but without testing machine it can be too much risk! New versions
> of kernel can break your applications (sometimes they should be at
> least rebuilded).
>
> So, maybe you would better try this, 'less testing', version of my patch:
>
>   
I risk only if RC kernel broke hardware. Mashines use only iptables and 
TC. All Scrips backuped.
But if i need to reboot PC by hand (if it freeze) i need drive to 
servers-room =)

 > BTW, I think after this BUG could be something more about other CPUs.
 > Could you check this?

I send to you all info that catch NETCONSOLE. i don't cut any info...

Now 1 mashine work at *"2.6.23-rc4-git2 
<http://kernel.org/pub/linux/kernel/v2.6/snapshots/patch-2.6.23-rc4-git2.bz2>" 
Backup mashine use 2.6.18*

