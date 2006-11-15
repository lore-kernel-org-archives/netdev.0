From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] prefix: Convert RTM_NEWPREFIX notifications to use the
 new netlink api
Date: Tue, 14 Nov 2006 19:54:42 -0800 (PST)
Message-ID: <20061114.195442.75429472.davem@davemloft.net>
References: <20061114142743.GS8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18919
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966103AbWKODyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 22:54:40 -0500
To: tgraf@suug.ch
In-Reply-To: <20061114142743.GS8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 14 Nov 2006 15:27:43 +0100

> RTM_GETPREFIX is completely unused and is thus removed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied, thanks Thomas.
