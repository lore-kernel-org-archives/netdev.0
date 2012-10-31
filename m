From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] realtek: r8169: use module_pci_driver macro
Date: Wed, 31 Oct 2012 14:04:23 -0400 (EDT)
Message-ID: <20121031.140423.1473598712723129102.davem@davemloft.net>
References: <1351279662-16466-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964944Ab2JaSE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 14:04:27 -0400
In-Reply-To: <1351279662-16466-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Fri, 26 Oct 2012 15:27:42 -0400

> use the module_pci_driver macro to make the code simpler
> by eliminating the module_init and module_exit calls
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
