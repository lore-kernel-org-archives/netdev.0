From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v3 2/3] net: TCP thin linear timeouts
Date: Sat, 13 Feb 2010 16:49:20 +0100
Message-ID: <4B76CA00.4060809@simula.no>
References: <4B73F30D.6040205@simula.no> <1265946733.2891.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.2750.no ([62.101.244.198]:59381 "EHLO mail.2750.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255Ab0BMP6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Feb 2010 10:58:12 -0500
In-Reply-To: <1265946733.2891.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12. feb. 2010 04:52, Eric Dumazet wrote:
>
> Hi Anreas
>
> Could you include a section in Documentation/networking/ip-sysctl.txt
> about tcp_force_thin_linear_timeouts setting ?
>

I 'll submit a draft with the next iteration. thanks for the heads up on the procedure.
It may also be helpful with a separate textfile to describe the thin-stream latency
issues and the mechanisms. I will submit a draft for this also.

> Also, you should provide some documentation to be included in man pages
> (man 7 tcp), to Michael Kerrisk ( <mtk.manpages@gmail.com> ), both for
> tcp_force_thin_linear_timeouts and TCP_THIN_LT
>
> (Same applies for patch 3/3 and tcp_force_thin_dupack /
> TCP_THIN_DUPACK )
>   

I'll make a draft, and mail him as soon as the naming issues are settled.

Best regards,
Andreas
