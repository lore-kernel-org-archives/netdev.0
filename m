From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] blackfin_mac: unneeded assignment
Date: Tue, 29 Jul 2008 18:24:48 -0400
Message-ID: <488F98B0.8070807@pobox.com>
References: <20080725114646.35f99145@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cooloney@kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43911 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662AbYG2WYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 18:24:53 -0400
In-Reply-To: <20080725114646.35f99145@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> skb->dev is set by eth_type_trans already.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied


