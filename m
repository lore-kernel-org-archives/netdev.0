From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/4] ibmveth: change rx buffer default
 allocation for CMO
Date: Thu, 30 Apr 2015 16:34:06 -0400 (EDT)
Message-ID: <20150430.163406.1457837182974039043.davem@davemloft.net>
References: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	brking@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbD3UeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:34:09 -0400
In-Reply-To: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 29 Apr 2015 16:25:44 -0500

> This patch enables 64k rx buffer pools by default.  If Cooperative
> Memory Overcommitment (CMO) is enabled, the number of 64k buffers
> is reduced to save memory.
> 
> Cc: Brian King <brking@linux.vnet.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
