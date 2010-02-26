From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] rtnetlink: clean up SR-IOV config
 interface
Date: Fri, 26 Feb 2010 04:19:57 -0800 (PST)
Message-ID: <20100226.041957.180033137.davem@davemloft.net>
References: <20100225075950.18665.50738.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48552
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934992Ab0BZMTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:19:40 -0500
In-Reply-To: <20100225075950.18665.50738.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Feb 2010 23:59:56 -0800

> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> This patch consists of a few minor cleanups to the SR-IOV
> configurion code in rtnetlink.
> - Remove unneccesary lock
> - Remove unneccesary casts
> - Return correct error code for no driver support
> 
> These changes are based on comments from Patrick McHardy
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
