From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: Changes to GRO for encapsulation
Date: Tue, 09 Sep 2014 12:18:51 -0700 (PDT)
Message-ID: <20140909.121851.1011635198160178838.davem@davemloft.net>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbaIITSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 15:18:51 -0400
In-Reply-To: <1410153989-23837-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun,  7 Sep 2014 22:26:24 -0700

> This patch set has some fixes for encapsulation and GRO.
> 
> Tom Herbert (5):
>   net: Fix GRE RX to use skb_transport_header for GRE header offset
>   ipip: Add gro callbacks to ipip offload
>   sit: Add gro callbacks to sit offload
>   udp: Add try convert checksum is case of skb_steal_sock
>   net: Export inet_offloads and inet6_offloads

Please address Eric's feedback and respin this series, thanks!
