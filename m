From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Fri, 19 Mar 2010 06:45:13 +0100
Message-ID: <1268977513.2894.223.camel@edumazet-laptop>
References: <1268955460.2894.207.camel@edumazet-laptop>
	 <20100318.222226.191403090.davem@davemloft.net>
	 <1268976491.2894.221.camel@edumazet-laptop>
	 <20100318.223658.241427584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:44314 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab0CSFpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:45:19 -0400
Received: by bwz25 with SMTP id 25so1396142bwz.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:45:16 -0700 (PDT)
In-Reply-To: <20100318.223658.241427584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 mars 2010 =C3=A0 22:36 -0700, David Miller a =C3=A9crit :
> It was not an issue of related, but rather "B won't apply cleanly
> without A". Even line offsets can make "git apply" reject.
> --

I see, I can resubmit later if you prefer, once net-2.6 fix is pulled i=
n
net-next, there is no hurry :)



