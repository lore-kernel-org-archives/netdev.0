From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: Oops in IFB
Date: Thu, 20 Jul 2006 16:29:35 +0200
Message-ID: <44BF934F.8050708@6wind.com>
References: <44BF8628.9080204@6wind.com>  <1153402801.5098.66.camel@jzny2> <1153403893.5098.79.camel@jzny2>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:40458 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S1030322AbWGTO00
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 10:26:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1153403893.5098.79.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal a =E9crit :
> BTW, in the name of the LinuxWay(tm) - can you also submit a similar
> patch for dummy? It suffers from the same bug.
No problem, patch is enclosed.

Cheers,
Nicolas

[DUMMY] Avoid an oops when dummy_init_one() failed

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
