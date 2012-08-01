From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils - ping and ping6
Date: Wed, 01 Aug 2012 13:08:26 +0900
Message-ID: <5018ABBA.9010706@linux-ipv6.org>
References: <500CFBA9.7010807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jan Synacek <jsynacek@redhat.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:47292 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750814Ab2HAEIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 00:08:31 -0400
In-Reply-To: <500CFBA9.7010807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2012/07/23 16:22), Jan Synacek wrote:
> Hello Hideaki-san,
>
> currently, ping and ping6 drop all the capabilities regardless of whether the
> user wants to set marks (-m option) or not. Setting marks requires
> cap_net_admin, though, and doesn't work.
>
> This patch defers the dropping if the "-m" is specified and correct capability
> is set.

Applied, Thank you.

Please add signed-off line next time. Thank you.

--yoshfuji
