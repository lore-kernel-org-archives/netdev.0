From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 6/6] ixgbe: enable hardware offload for sctp
Date: Tue, 28 Apr 2009 01:55:04 -0700 (PDT)
Message-ID: <20090428.015504.114151765.davem@davemloft.net>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
	<20090428083634.32417.6021.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753770AbZD1IzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:55:10 -0400
In-Reply-To: <20090428083634.32417.6021.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:36:35 -0700

> Inspired by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> This is the code to enable ixgbe for hardware offload support
> of CRC32c on both transmit and receive of SCTP traffic.
> 
> only 82599 supports this offload, not 82598.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
