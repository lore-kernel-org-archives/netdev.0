From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Thu, 16 Jun 2011 23:33:54 -0400 (EDT)
Message-ID: <20110616.233354.508986372720173787.davem@davemloft.net>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: carolyn.wyborny@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059Ab1FQDeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:34:07 -0400
In-Reply-To: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Date: Tue, 14 Jun 2011 10:13:26 -0700

> This RFC patch adds functions to get and set DMA Coalescing feature
> configuration.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>

What in the world is "DMA Coalescing feature", what does it do?

Might it want parameters and not just want to be turned on or off?

This change, at a minimum, needs a more descriptive commit log entry.
So that other driver authors can understand what exactly the feature
is and therefore whether they might like to add support for it to
their drivers.
