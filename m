From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] bna: Enable ethtool flash management and debugfs
 interface.
Date: Fri, 23 Dec 2011 16:53:24 -0500 (EST)
Message-ID: <20111223.165324.1792767022324983695.davem@davemloft.net>
References: <1324596547-7646-1-git-send-email-kgudipat@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.com,
	rmody@Brocade.com
To: kgudipat@Brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757909Ab1LWVy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 16:54:27 -0500
In-Reply-To: <1324596547-7646-1-git-send-email-kgudipat@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <kgudipat@Brocade.com>
Date: Thu, 22 Dec 2011 15:29:07 -0800

> 	The following patch-set enhances BNA ethtool to support flash management
> using eeprom entry points and also enables debugfs support for BNA driver to
> collect firmware traces, saved firmware trace in the flash on an IOC crash and to
> perform register reads/writes.
> 
> 	The patch is compiled and tested against latest net-next kernel.

Both applied, thanks.
