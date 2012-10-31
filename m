From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dlink: dl2k: use the module_pci_driver macro
Date: Wed, 31 Oct 2012 14:04:34 -0400 (EDT)
Message-ID: <20121031.140434.871236128029691847.davem@davemloft.net>
References: <1351279740-16519-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933566Ab2JaSEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 14:04:37 -0400
In-Reply-To: <1351279740-16519-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Fri, 26 Oct 2012 15:29:00 -0400

> use the module_pci_driver macro to make the code simpler
> by eliminating module_init and module_exit calls.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
