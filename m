From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 12:25:22 +0400
Message-ID: <46D7D072.5060508@bigtelecom.ru>
References: <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:42808 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737AbXHaIZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 04:25:25 -0400
In-Reply-To: <20070831075909.GA1772@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i not have testing mashine.
we have 2 mashine and dynamic routing. if 1 mashine down - all traffic 
go to second mashine.
I can test is on this mashines but i need that testing mashine will 
reboot on kernel panic (sysctl message). No freezes =)

Ok. i try 2.6.23-rc4.

> On Fri, Aug 31, 2007 at 11:04:21AM +0400, Badalian Vyacheslav wrote:
>   
>> I try you patch. Also i try add more debug options to kernel. I catch 
>> (BUG: spinlock lockup on CPU#3, tc/6403, f742e200)
>> All info in file. Ready for next patch ;)
>>     
>
> I've to look at this, but actually my patch wrongly added this one
> warning. I hope you did this on a testing machine...
>
> Anyway there could be something new but I need some time. If possible,
> 2.6.23-rc4 should be the best thing for testing yet.
>
> Thanks,
> Jarek P.
>
>   

