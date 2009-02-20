From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] igb: Add support for enabling VFs to PF
 driver.
Date: Fri, 20 Feb 2009 00:23:40 -0800 (PST)
Message-ID: <20090220.002340.46838151.davem@davemloft.net>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
	<20090220044006.29650.54737.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, yu.zhao@intel.com,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755971AbZBTIX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:23:58 -0500
In-Reply-To: <20090220044006.29650.54737.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Feb 2009 20:40:07 -0800

> This patch adds the support to handle requests from the VF to perform
> operations such as completing resets, setting/reading mac address, adding
> vlans, adding multicast addresses, setting rlpml, and general
> communications between the PF and all VFs.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
