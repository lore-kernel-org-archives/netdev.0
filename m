From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: Display EEPROM version in ethtool
 -i queries
Date: Thu, 05 Feb 2009 23:55:09 -0800 (PST)
Message-ID: <20090205.235509.114349188.davem@davemloft.net>
References: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
	<20090205013943.29241.71108.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752051AbZBFHzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:55:13 -0500
In-Reply-To: <20090205013943.29241.71108.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 04 Feb 2009 17:39:43 -0800

> Currently ixgbe does not display the EEPROM version in ethtool -i, where
> other drivers do.  The EEPROM version is located at offset 0x29.  This
> patch adds support to display it.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
