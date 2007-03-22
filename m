From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] [PATCHSET] netlink error management
Date: Thu, 22 Mar 2007 12:23:55 -0700 (PDT)
Message-ID: <20070322.122355.48516149.davem@davemloft.net>
References: <20070321231801.342849239@lsx.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933980AbXCVTXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:23:55 -0400
In-Reply-To: <20070321231801.342849239@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 Mar 2007 00:18:01 +0100

> This series of patches simplifies the error management and
> signalization of dump starts of netlink_run_queue() message
> handlers. It touches a fair bit of nfnetlink code as the
> error pointer has been passed on to subsystems.

Thomas can you respin these patches?  They no longer apply
now that I put your other rtnl_link bits into net-2.6.22

Thanks.
