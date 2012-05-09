From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Lksctp-developers] Bug: sctp packets are dropped after IPSEC
 rekeying (route cache issue)
Date: Wed, 09 May 2012 14:04:10 +0200
Message-ID: <4FAA5D3A.7080706@6wind.com>
References: <4C46AA7B.3090601@6wind.com> <4C46FD58.9030107@hp.com> <4FA3AA6A.4070503@6wind.com> <20120504.104812.502049217620285020.davem@davemloft.net> <4FA3F4C6.7070605@6wind.com> <CAGCdqXFjyWst22DJgxNfakz3-JwRq0Z+WZVj-XT=qRQFY5w3rw@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, babu.srinivasan@gmail.com,
	lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	michael.kreuzer@nsn.com
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49902 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757459Ab2EIMEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 08:04:15 -0400
Received: by bkcji2 with SMTP id ji2so181096bkc.19
        for <netdev@vger.kernel.org>; Wed, 09 May 2012 05:04:14 -0700 (PDT)
In-Reply-To: <CAGCdqXFjyWst22DJgxNfakz3-JwRq0Z+WZVj-XT=qRQFY5w3rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/05/2012 20:15, Vladislav Yasevich a =E9crit :
> On Fri, May 4, 2012 at 11:24 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com>wrote:
>
>> Le 04/05/2012 16:48, David Miller a =E9crit :
>>
>>   From: Nicolas Dichtel<nicolas.dichtel@6wind.**com<nicolas.dichtel@=
6wind.com>
>>>>
>>> Date: Fri, 04 May 2012 12:07:38 +0200
>>>
>>>   Finally, this patch was never integrated into the mainline. Shoul=
d I
>>>> rebase it on the head?
It applies cleanly on linus tree, so I will not rebase it.


Regards,
Nicolas

>>>>
>>>> I've attach the last approved patch.
>>>>
>>>> Here is the original thread:
>>>> http://sourceforge.net/**mailarchive/message.php?msg_**id=3D257860=
06<http://sourceforge.net/mailarchive/message.php?msg_id=3D25786006>
>>>>
>>>
>>> Vlad no longer works for HP so your email likely will bounce, and
>>> he will not see it.
>>>
>> Right.
>>
>>
>>
>>> His new email address is vyasevich@gmail.com, as per the MAINTAINER=
S
>>> file.
>>>
>>
>> I put the right email address now. I attach the patch again, for Vla=
d.
>>
>>
>> Thank you,
>> Nicolas
>>
>
>
> Right.  This looks fine.
>
> Acked-by: Vlad Yaseivch<vyasevich@gmail.com>
