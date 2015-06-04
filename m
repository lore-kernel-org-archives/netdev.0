From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 04 Jun 2015 13:58:07 -0700
Message-ID: <5570BBDF.3080309@roeck-us.net>
References: <20150516131628.GA981@gondor.apana.org.au>	<20150516.171019.1206903516753105739.davem@davemloft.net>	<20150604162727.GA2670@roeck-us.net> <20150604.115922.1489867293287036693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37252 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbbFDU6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 16:58:11 -0400
In-Reply-To: <20150604.115922.1489867293287036693.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2015 11:59 AM, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Thu, 4 Jun 2015 09:27:27 -0700
>
>> sorry for bothering you - I don't see this patch in any of your trees,
>> and it is marked as "changes requested" in patchwork. Did I look
>> at the wrong places, do you still plan to apply the patch as-is,
>> or do you expect some changes ?
>>
>> As side info, I have been trying to track down the getaddrinfo
>> hang problem observed by others, which we see in 3.19.4 and 4.0.4.
>
> Changes-requested, amazingly, means that someone gave you feedback
> and changes along with a fresh resubmission is expected of you.
>

Yes, I understand. My problem is/was that your last e-mail on the subject
suggested that you would apply the patch, while at the same time patchwork
suggests that you expect to see changes. Sorry that I was - and still
am - unable to correlate those two pieces of information.

Guenter
