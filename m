From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tcp: add tcp_available_congestion_control sysctl
Date: Thu, 09 Nov 2006 16:32:19 -0800 (PST)
Message-ID: <20061109.163219.101116872.davem@davemloft.net>
References: <20061031230140.191929094@osdl.org>
	<20061031230213.704489579@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5764
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424309AbWKJAca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:32:30 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031230213.704489579@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 31 Oct 2006 15:01:42 -0800

> Create /proc/sys/net/ipv4/tcp_available_congestion_control
> that reflects currently available TCP choices.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
