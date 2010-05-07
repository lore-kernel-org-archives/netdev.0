From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: Various optimizations
Date: Fri, 07 May 2010 07:16:15 +0200
Message-ID: <1273209375.2222.37.camel@edumazet-laptop>
References: <1273136322.2357.15.camel@edumazet-laptop>
	 <20100506.220759.25136752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53651 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab0EGFQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:16:25 -0400
Received: by bwz19 with SMTP id 19so366792bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 22:16:24 -0700 (PDT)
In-Reply-To: <20100506.220759.25136752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 22:07 -0700, David Miller a =C3=A9crit :

> Looks great, applied, thanks Eric.

Thanks, I have a followup to avoid one atomic in enqueue phase too ;)


