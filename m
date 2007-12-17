From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr)
 functions
Date: Mon, 17 Dec 2007 14:41:15 -0800 (PST)
Message-ID: <20071217.144115.206059122.davem@davemloft.net>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
	<Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757335AbXLQWlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 17:41:16 -0500
In-Reply-To: <Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Mon, 17 Dec 2007 23:37:24 +0100 (CET)

> Can we use __constant_htonl()?

That should only be used in initializers.
