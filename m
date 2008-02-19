From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/17 net-2.6.26] [NETFILTER]: Consolidate masq_inet_event
 and masq_device_event.
Date: Tue, 19 Feb 2008 15:10:11 +0100
Message-ID: <47BAE343.4050206@trash.net>
References: <1203406116.27296.1.camel@iris.sw.ru> <1203406297-32725-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:4313 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752408AbYBSOK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:10:27 -0500
In-Reply-To: <1203406297-32725-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> They do exactly the same job.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  net/ipv4/netfilter/ipt_MASQUERADE.c |   14 ++------------
>  1 files changed, 2 insertions(+), 12 deletions(-)

Looks fine.
