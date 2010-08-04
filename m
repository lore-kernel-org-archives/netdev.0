From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/4] cls_flow: add sanity check for the packet length
Date: Wed, 04 Aug 2010 18:12:13 +0200
Message-ID: <4C59915D.1020902@trash.net>
References: <1280933292-12176-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51269 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313Ab0HDQM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:12:28 -0400
In-Reply-To: <1280933292-12176-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.08.2010 16:48, schrieb Changli Gao:
> The packet length should be checked before the packet data is dereferenced.
> 

Thanks.

Acked-by: Patrick McHardy <kaber@trash.net>

