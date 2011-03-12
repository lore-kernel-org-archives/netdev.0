From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 6/6] net: introduce rx_handler results and
 logic around that
Date: Sat, 12 Mar 2011 14:25:39 +0100
Message-ID: <4D7B7453.5040606@gmail.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com> <1299935679-18135-7-git-send-email-jpirko@redhat.com> <4D7B7403.6050402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37895 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab1CLNZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 08:25:41 -0500
Received: by wwa36 with SMTP id 36so4144634wwa.1
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 05:25:40 -0800 (PST)
In-Reply-To: <4D7B7403.6050402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/03/2011 14:24, Nicolas de Peslo=C3=BCan a =C3=A9crit :
> Le 12/03/2011 14:14, Jiri Pirko a =C3=A9crit :
>> This patch allows rx_handlers to better signalize what to do next to
>> it's caller. That makes skb->deliver_no_wcard no longer needed.
>>
>> kernel-doc for rx_handler_result is taken from Nicolas' patch.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>> eviewed-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
>
> Typo in [R]eviewed-by and missing space between Peslo=C3=BCan and <ni=
colas.
>
> Nicolas.

Only the missing R in Reviewed-by:. The space was removed by my mail cl=
ient, sorry.

	Nicolas.

