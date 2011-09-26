From: Breno Leitao <brenohl@br.ibm.com>
Subject: Re: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 15:56:35 -0300
Message-ID: <4E80CAE3.2040100@br.ibm.com>
References: <1316704497.29549.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1317057325-7410-1-git-send-email-brenohl@br.ibm.com> <1317060132.2796.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:60716 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab1IZS5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 14:57:55 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Mon, 26 Sep 2011 15:57:53 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QIxuUI1159584
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 16:00:06 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QIukSd026283
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 15:56:47 -0300
In-Reply-To: <1317060132.2796.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 03:02 PM, Eric Dumazet wrote:
> You should move in ehea_get_stats() all software-computed stats.
Agreed. I am going to resend the patch.

Thanks
