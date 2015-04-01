From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: kdump related fixes
Date: Wed, 01 Apr 2015 12:30:59 -0400 (EDT)
Message-ID: <20150401.123059.1027419708160538492.davem@davemloft.net>
References: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbbDAQbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 12:31:02 -0400
In-Reply-To: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 1 Apr 2015 10:02:18 +0300

> This patch series aims to fix bnx2x driver issues when loading in kdump kernel.
> Both issues fixed here would be fatal to the device, requiring full reset of
> the system in order to recover, preventing the device from serving its purpose
> in the kdump environment.

Series applied, thank you.
