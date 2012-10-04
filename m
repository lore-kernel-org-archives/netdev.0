From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 1/2] sctp: fix a typo in prototype of __sctp_rcv_lookup()
Date: Thu, 04 Oct 2012 09:17:04 +0200
Message-ID: <506D37F0.5000804@6wind.com>
References: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com> <20121003.162847.312544751568068374.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42714 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab2JDHRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 03:17:10 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so107684eek.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 00:17:09 -0700 (PDT)
In-Reply-To: <20121003.162847.312544751568068374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/10/2012 22:28, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Wed,  3 Oct 2012 17:43:21 +0200
>
>> Just to avoid confusion when people only reads this prototype.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> I think we should apply this one, regardless of what happens
> to patch #2 in this series.
>
Yes, I catch it when working on the second patch, but I should send two=
 seperate=20
patches.
