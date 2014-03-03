From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/4]
Date: Sun, 02 Mar 2014 19:19:06 -0500 (EST)
Message-ID: <20140302.191906.37467334104875774.davem@davemloft.net>
References: <1393631338-18847-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbaCCATH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:19:07 -0500
In-Reply-To: <1393631338-18847-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Fri, 28 Feb 2014 15:48:54 -0800

> Mark updates ixgbe for LER / adapter removal.  He restores the HW
> address in the recovery path so the device is not perpetually removed,
> fixes up some removed state ethtool results and adds checks related to
> config space access.
> 
> Jacob adds support for the new SIOCGHWTSTAMP ioctl.

[ Note, empty subject ]

Series applied, thanks.
