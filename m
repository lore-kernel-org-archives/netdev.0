From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/6] netns: advertise netns via netlink
Date: Mon, 26 Jan 2015 10:20:45 +0100
Message-ID: <54C606ED.6060305@6wind.com>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com> <20150123.175142.618148236781483266.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:44739 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbAZJUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 04:20:48 -0500
Received: by mail-we0-f177.google.com with SMTP id l61so7840269wev.8
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 01:20:47 -0800 (PST)
In-Reply-To: <20150123.175142.618148236781483266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/01/2015 02:51, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 20 Jan 2015 15:15:41 +0100
>
>>
>> The first patch of the serie fix a bug of the previous serie (presen=
t in
>> net-next only).
>> The rest of the serie adds an attribute to advertise the peer netns =
for
>> rtnetlink messages where this information is needed by userland to b=
e able to
>> interpret fully the received message.
>
> "series" has a final 's'.  Well, as least you consistently misspell i=
t
> 3 times :-)
Thanks for noticing it.
=46or the story, it comes from the french word 'serie' which don't end =
with a 's'
;-)
