From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/49] pcmcia: deprecate CS_SUCCESS
Date: Mon, 13 Oct 2008 11:41:25 -0700 (PDT)
Message-ID: <20081013.114125.243859487.davem@davemloft.net>
References: <20081013173803.GA18569@comet.dominikbrodowski.net>
	<1223920114-19788-22-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org
To: linux@dominikbrodowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756861AbYJMSlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 14:41:49 -0400
In-Reply-To: <1223920114-19788-22-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Mon, 13 Oct 2008 19:48:07 +0200

> Instead of using own error or success codes, the PCMCIA code should rely on
> the generic return values. Therefore, replace all occurrences of CS_SUCCESS
> with 0.
> 
> CC: netdev@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

For networking parts:

Acked-by: David S. Miller <davem@davemloft.net>
