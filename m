From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] caif: remove wrong dev_net_set() call
Date: Tue, 27 Jan 2015 13:50:15 +0100
Message-ID: <54C78987.7020908@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>	<1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>	<54C777D0.6090608@6wind.com> <874mrcwg3q.fsf@nemi.mork.no>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	dmitry.tarnyagin@lockless.no, arvid.brodin@alten.se,
	alex.aring@gmail.com, linux-wpan@vger.kernel.org,
	=?UTF-8?B?U2p1ciBCcsOm?= =?UTF-8?B?bmRlbGFuZA==?=
	<sjur.brandeland@stericsson.com>,
	Dmitry Tarnyagin <abi.dmitryt@gmail.com>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41546 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465AbbA0MuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:50:18 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so4715114wid.5
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 04:50:17 -0800 (PST)
In-Reply-To: <874mrcwg3q.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/01/2015 13:41, Bj=C3=B8rn Mork a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>>> CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
>>> CC: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
>>
>> I got a "Delivery Status Notification (Failure)" for Dmitry Tarnyagi=
n
>> (I took the email address from the MAINTAINERS file):
>>
>>    Delivery to the following recipient failed permanently:
>>
>>         dmitry.tarnyagin@lockless.no
>>
>>    Technical details of permanent failure:
>>    Google tried to deliver your message, but it was rejected by the =
server for
>>    the recipient domain lockless.no by mail.lockless.no. [46.29.221.=
38].
>>
>>    The error that the other server returned was:
>>    550 5.1.1 <dmitry.tarnyagin@lockless.no>: Recipient address rejec=
ted: User
>>    unknown in virtual mailbox table
>>
>> Any suggestions?
>
>
> He used a gmail address in commit dd9dfb9f95e2 ("cfg80211: merge in
> beacon ies of hidden bss.").  Probably by accident, but worth trying
> anyway...
Ok, I will wait a bit before trying this address.

>
> I guess the stericsson.com addresses could be failing silently now? R=
ef
> http://stericsson.com/ . Or are they still routed to the named recepi=
ents?
I got also a delivery failure for sjur.brandeland@stericsson.com


Thank you,
Nicolas
