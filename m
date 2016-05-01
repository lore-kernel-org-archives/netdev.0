From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] qed/qede: ethtool selftests support.
Date: Sun, 01 May 2016 19:43:58 -0400 (EDT)
Message-ID: <20160501.194358.139685458712484423.davem@davemloft.net>
References: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com, manish.chopra@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbcEAXoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:44:01 -0400
In-Reply-To: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Thu, 28 Apr 2016 20:20:51 -0400

> This series adds the driver support for following selftests:
> 1. Register test
> 2. Memory test
> 3. Clock test
> 4. Interrupt test
> 5. Internal loopback test
> Patch (1) adds the qed driver infrastructure for selftests. Patches (2) and
> (3) add qede driver support for ethtool selftests.
> 
> Please consider applying this series to "net-next".

Series applied, thanks.
