From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add packet capture support on macvtap
 device
Date: Thu, 12 Dec 2013 13:39:50 -0500 (EST)
Message-ID: <20131212.133950.2010526901273479418.davem@davemloft.net>
References: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, kaber@trash.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220Ab3LLSjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:39:53 -0500
In-Reply-To: <1386786431-22592-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 11 Dec 2013 13:27:09 -0500

> Change from RFC:
>   - moved to the rx_handler approach.

Eric's feedback about contention is legitimate, but I think you can
deal with this in follow-on patches, so I've applied this series to
net-next.

Thanks!
