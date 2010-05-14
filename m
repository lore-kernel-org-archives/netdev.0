From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] e1000: cleanup unused parameters
Date: Fri, 14 May 2010 03:14:45 -0700 (PDT)
Message-ID: <20100514.031445.91353115.davem@davemloft.net>
References: <20100514012425.30457.23799.stgit@localhost.localdomain>
	<20100514012554.30457.66528.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758869Ab0ENKOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 06:14:36 -0400
In-Reply-To: <20100514012554.30457.66528.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 18:25:56 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> During the cleanup pass after the removal of e1000e hardware from e1000 some
> parameters were missed.  Remove them because it is just dead code.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
