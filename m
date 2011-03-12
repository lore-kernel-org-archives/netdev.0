From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 6/6] net: introduce rx_handler results and
 logic around that
Date: Sat, 12 Mar 2011 14:36:44 +0100
Message-ID: <20110312133643.GB2899@psychotron.redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
 <1299935679-18135-7-git-send-email-jpirko@redhat.com>
 <4D7B7403.6050402@gmail.com>
 <4D7B7453.5040606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589Ab1CLNgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:36:48 -0500
Content-Disposition: inline
In-Reply-To: <4D7B7453.5040606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 12, 2011 at 02:25:39PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 12/03/2011 14:24, Nicolas de Peslo=FCan a =E9crit :
>>Le 12/03/2011 14:14, Jiri Pirko a =E9crit :
>>>This patch allows rx_handlers to better signalize what to do next to
>>>it's caller. That makes skb->deliver_no_wcard no longer needed.
>>>
>>>kernel-doc for rx_handler_result is taken from Nicolas' patch.
>>>
>>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>eviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>
>>Typo in [R]eviewed-by and missing space between Peslo=FCan and <nicol=
as.
>>
>>Nicolas.
>
>Only the missing R in Reviewed-by:. The space was removed by my mail c=
lient, sorry.

Copypaste err :( Sorry..

Dave would you please add "R" before you apply. Many thanks.

Jirka
>
>	Nicolas.
>
