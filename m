From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH net-next-2.6] macb: straighten out macb_mii_probe
 function
Date: Wed, 10 Feb 2010 15:17:06 +0530
Message-ID: <20100210151706.6f12d431@hskinnemoen-d830>
References: <20100208151207.GE2601@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hskinnemoen@atmel.com, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:56627 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373Ab0BJQ4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 11:56:12 -0500
In-Reply-To: <20100208151207.GE2601@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:
> Use "phy_find_first" instead of manual lookup. Also use "phy_connect_direct"
> instead of "phy_connect" since we already have phy_device pointer here.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Looks reasonable as far as I can see.

Acked-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
