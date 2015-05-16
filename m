From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: nicer log message on Siena SR-IOV probe
 fail
Date: Sat, 16 May 2015 18:02:52 -0400 (EDT)
Message-ID: <20150516.180252.1029792726719975770.davem@davemloft.net>
References: <55564F73.6010308@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbEPWDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 18:03:05 -0400
In-Reply-To: <55564F73.6010308@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 15 May 2015 20:56:35 +0100

> We expect that MC_CMD_SRIOV will fail if the card has no VFs configured.
> So output a readable message instead of a cryptic MCDI error.

Please resubmit this patch with a proper "Signed-off-by: " tag.

Thank you.
