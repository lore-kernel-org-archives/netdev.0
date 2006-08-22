From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] IPv6 FIB configuration conversions
Date: Tue, 22 Aug 2006 00:02:10 -0700 (PDT)
Message-ID: <20060822.000210.01044094.davem@davemloft.net>
References: <20060816234038.106537101@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35756
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751303AbWHVHBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:01:55 -0400
To: tgraf@suug.ch
In-Reply-To: <20060816234038.106537101@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 17 Aug 2006 01:40:38 +0200

> Same approach as for IPv4, simplifies the interface
> and makes it extendable without breaking the ioctl
> interface.
> 
> Same memory corruption fixes in RTM_GETROUTE as for IPv4.

Applied, thanks a lot Thomas.
