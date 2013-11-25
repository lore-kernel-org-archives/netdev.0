From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] dccp: restore header formatting
Date: Mon, 25 Nov 2013 01:51:27 -0800 (PST)
Message-ID: <20131125.015127.618931844978352797.davem@davemloft.net>
References: <20131124191823.427c4a8a@liptov.cs.ualberta.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab3KYJmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 04:42:50 -0500
In-Reply-To: <20131124191823.427c4a8a@liptov.cs.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 24 Nov 2013 19:18:23 -0700

> -int dccp_ackvec_init(void);
> +int  dccp_ackvec_init(void);

This is absolutely not acceptable, there is no reason to have two spaces
between the return type and the function name.
