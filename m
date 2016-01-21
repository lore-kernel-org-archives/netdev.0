From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v3)
Date: Thu, 21 Jan 2016 13:17:07 +0800
Message-ID: <56A069D3.1080409@oracle.com>
References: <1453267933-25381-1-git-send-email-wen.gang.wang@oracle.com>
 <569F2806.70608@gmail.com> <569F397B.7010808@oracle.com>
 <569F3D19.8020307@gmail.com> <569F579F.1060708@oracle.com>
 <569F59D8.2060200@gmail.com> <56A04522.9010300@oracle.com>
 <24100.1453349129@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29713 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758599AbcAUFNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 00:13:54 -0500
In-Reply-To: <24100.1453349129@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=D4=DA 2016=C4=EA01=D4=C221=C8=D5 12:05, Jay Vosburgh =D0=B4=B5=C0:
> Wengang Wang <wen.gang.wang@oracle.com> wrote:
> [...]
>> For ipip,  yes seems update_pmtu is called in line for each call of
>> queue_xmit.  Do you know if it's a good configuration for ipip + bon=
ding?
> 	Yes, it is.
>
>> Other's comment and suggestion?
> 	I agree with Sabrina Dubroca <sd@queasysnail.net>'s suggestions
> from yesterday.

Thank you! I will follow.

thanks,
wengang
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
