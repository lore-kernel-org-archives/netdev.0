From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: always set header length in
 SRRCTL
Date: Thu, 07 May 2009 14:55:58 -0700 (PDT)
Message-ID: <20090507.145558.234365404.davem@davemloft.net>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34446
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752554AbZEGV4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:03 -0400
In-Reply-To: <20090507203854.19886.54737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 May 2009 13:38:56 -0700

> As per the documentation for 82599 in order to support hardware RSC the
> header size must be set.  This is only currently done for packet split
> mode.  This patch sets the header buffer length for all modes.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
