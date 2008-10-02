From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next PATCH 12/16] Split Netfilter IPv4 defragmentation into
 a	separate module
Date: Thu, 02 Oct 2008 11:18:00 +0200
Message-ID: <48E491C8.6080506@trash.net>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.63510.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52639 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbYJBJTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 05:19:02 -0400
In-Reply-To: <20081001142431.4893.63510.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KOVACS Krisztian wrote:
> Netfilter connection tracking requires all IPv4 packets to be defragmented.
> Both the socket match and the TPROXY target depend on this functionality, so
> this patch separates the Netfilter IPv4 defrag hooks into a separate module.
>
>   

Applied, thanks.

