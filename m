From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 5/5] soreuseport: UDP/IPv6 implementation
Date: Tue, 15 Jan 2013 05:27:53 +0900
Message-ID: <50F46A49.3030303@linux-ipv6.org>
References: <alpine.DEB.2.00.1301141139190.1968@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40064 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757347Ab3ANU1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:27:55 -0500
In-Reply-To: <alpine.DEB.2.00.1301141139190.1968@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> +				hash = inet6_ehashfn(net, daddr, hnum,
> +				    saddr, sport);
:
> +				hash = inet6_ehashfn(net, daddr, hnum,
> +				    saddr, sport);

Ditto.

--yoshfuji
