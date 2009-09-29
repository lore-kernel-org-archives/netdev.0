From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][RESEND] IPv6: 6rd tunnel mode
Date: Tue, 29 Sep 2009 14:57:30 +0900
Message-ID: <4AC1A1CA.3090808@linux-ipv6.org>
References: <20090922003956.GA19947@lnxos.staff.proxad.net>	 <4AB838F1.1090704@hp.com> <1253602772.17175.13.camel@lnxos-dev> <4AC196FB.4060408@linux-ipv6.org> <4AC19CD1.6060600@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: acassen@freebox.fr, Brian Haley <brian.haley@hp.com>,
	netdev@vger.kernel.org
To: Mark Townsley <townsley@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45396 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750721AbZI2F5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 01:57:38 -0400
In-Reply-To: <4AC19CD1.6060600@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, you mean, just in case if there are any IPRs?

--yoshfuji

Mark Townsley wrote:
> This is a general problem with all rfc editor submissions right now. It's not 
> because there is any IPR on the mechanism itself.
> 
> This is the current standards track version:
> 
> http://tools.ietf.org/id/draft-ietf-softwire-ipv6-6rd-00.txt
> 
> We are updating it now based on some discussions, should be published in a week 
> or so. Mostly minor updates. We are working with Remi closely on all of this.
> 
> This is the latest of Remi's independent drafts:
> 
> http://tools.ietf.org/html/draft-despres-6rd-03
> 
> - Mark
> 
> YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> Alexandre Cassen wrote:
>>
>>   
>>>> I couldn't find RFC 5569 (delayed due to IPR rights?), although I did find
>>>> the latest 6rd draft, -03.  It was showing as Informational, not Standards
>>>> track, is that right?  Just curious.
>>>>       
>>> In fact there is currently two draft :
>>>
>>> 1) https://datatracker.ietf.org/idtracker/draft-despres-6rd/
>>>
>>>    This draft is targeting informational RFC as an independent
>>> submission. It is currently queued and has been delayed since may for
>>> IPR.
>>>     
>>
>> Do you have any pointer about this (IPR)?
>> I probably missed something but I could not find any
>> information in IETF IPR page...
>>
>> --yoshfuji
>>
>>   
> 

