From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: make ops structs const
Date: Thu, 05 Jan 2012 13:23:12 -0500 (EST)
Message-ID: <20120105.132312.2097184941479195775.davem@davemloft.net>
References: <20120104135658.0347211f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab2AESXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:23:19 -0500
In-Reply-To: <20120104135658.0347211f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Jan 2012 13:56:58 -0800

> All tables of function pointers should be const to make hacks
> more difficult. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
