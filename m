From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] qed: Bandwidth configuration support
Date: Tue, 26 Apr 2016 13:56:45 -0400 (EDT)
Message-ID: <20160426.135645.142819000198473420.davem@davemloft.net>
References: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbcDZR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:56:49 -0400
In-Reply-To: <1461682570-745-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 26 Apr 2016 10:56:07 -0400

> This series adds support in driver for min/max bandwidth configuration
> for the PF on the link change notification or on explicit request of
> bandwidth update from the MFW [management firmware].
> 
> The same infrastructure would later be used by user based flows
> [for example, rate shaping for the VFs]
> 
> Please consider applying this series to "net-next"

Series applied, thanks.
