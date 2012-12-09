From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/5] tunneling: Add support for
 hardware-offloaded encapsulation
Date: Sun, 09 Dec 2012 00:21:41 -0500 (EST)
Message-ID: <20121209.002141.995257188036827568.davem@davemloft.net>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, chrisw@sous-sol.org, gospo@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com,
	bhutchings@solarflare.com
To: joseph.gasparakis@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab2LIFVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:21:44 -0500
In-Reply-To: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Date: Fri,  7 Dec 2012 16:14:13 -0800

> The series contains updates to add in the NIC Rx and Tx checksumming
> support for encapsulated packets.

Ok, all applied (except the ixgbe patch, of course), thanks.
