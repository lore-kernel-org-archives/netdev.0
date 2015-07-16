From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmveth: add support for TSO6
Date: Wed, 15 Jul 2015 21:35:18 -0700 (PDT)
Message-ID: <20150715.213518.1391748312035384335.davem@davemloft.net>
References: <1436889111-10509-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, brking@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbGPEfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:35:19 -0400
In-Reply-To: <1436889111-10509-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue, 14 Jul 2015 10:51:51 -0500

> This patch adds support for a new method of signalling the firmware
> that TSO packets are being sent. The new method removes the need to
> alter the ip and tcp checksums and allows TSO6 support.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
