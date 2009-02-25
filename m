From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [net-next] qlge: Clean up mac address and frame
 route settings.
Date: Tue, 24 Feb 2009 23:51:34 -0800 (PST)
Message-ID: <20090224.235134.47859129.davem@davemloft.net>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756908AbZBYHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:51:53 -0500
In-Reply-To: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 23 Feb 2009 12:42:13 -0800

> Setting MAC addresses and routing frames to various queues will need to
> be done in response to firmware events as well as during initialization.
> This change encapsulates the facilities into a single call that can
> later me made from other places.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
