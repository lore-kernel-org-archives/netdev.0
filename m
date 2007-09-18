From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: Tue, 18 Sep 2007 15:31:14 +0200
Message-ID: <46EFD322.10008@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de> <20070917100437.18347.1@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37427 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752236AbXIRNhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 09:37:54 -0400
In-Reply-To: <20070917100437.18347.1@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> This patch adds a protocol/address family number, ARP hardware type,
> ethernet packet type, and a line discipline number for the SocketCAN
> implementation.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>

Acked-by: Patrick McHardy <kaber@trash.net>

