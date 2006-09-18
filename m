From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] address: Convert address dumping to new netlink api
Date: Mon, 18 Sep 2006 00:12:44 -0700 (PDT)
Message-ID: <20060918.001244.85685751.davem@davemloft.net>
References: <20060901213957.138695086@lsx.localdomain>
	<20060901214014.912617720@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59091
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965518AbWIRHMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:12:45 -0400
To: tgraf@suug.ch
In-Reply-To: <20060901214014.912617720@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 01 Sep 2006 23:40:03 +0200

> Replaces INET6_IFADDR_RTA_SPACE with a new function calculating
> the total required message size for all address messages.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
