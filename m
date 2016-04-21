From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] NLA_BINARY misuse bug in HSR
Date: Thu, 21 Apr 2016 13:59:20 -0400 (EDT)
Message-ID: <20160421.135920.161658978282310799.davem@davemloft.net>
References: <20160419113428.GA10532@aircraft-controller>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
	daniel@iogearbox.net, julia.lawall@lip6.fr, peter.heise@airbus.com
To: mail@pheise.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbcDUR7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:59:22 -0400
In-Reply-To: <20160419113428.GA10532@aircraft-controller>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Heise <mail@pheise.de>
Date: Tue, 19 Apr 2016 13:34:28 +0200

> Removed .type field from NLA to do proper length checking.
> Reported by Daniel Borkmann and Julia Lawall.
> 
> Signed-off-by: Peter Heise <peter.heise@airbus.com>

Applied.
