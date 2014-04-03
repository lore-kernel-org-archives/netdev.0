From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] pf_packet fixes
Date: Thu, 03 Apr 2014 14:29:33 -0400 (EDT)
Message-ID: <20140403.142933.654380455828026709.davem@davemloft.net>
References: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbaDCS2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 14:28:01 -0400
In-Reply-To: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  2 Apr 2014 20:52:55 +0200

> Applies to net-next tree. Thanks!
> 
> Daniel Borkmann (2):
>   packet: report tx_dropped in packet_direct_xmit
>   packet: fix packet_direct_xmit for BQL enabled drivers

Series applied, thanks a lot.
