From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Enable forwarding for unknown to the
 CPU port
Date: Tue, 29 Sep 2015 21:07:18 -0700 (PDT)
Message-ID: <20150929.210718.1214734678591197693.davem@davemloft.net>
References: <1443484256-28873-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbI3EHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:07:18 -0400
In-Reply-To: <1443484256-28873-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 29 Sep 2015 01:50:56 +0200

> Frames destined to an unknown address must be forwarded to the CPU
> port. Otherwise incoming ARP, dhcp leases, etc, do not work.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
