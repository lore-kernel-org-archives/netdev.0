From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Use BUILD_BUG_ON in net/core/flowi.c
Date: Tue, 23 Oct 2007 21:15:56 -0700 (PDT)
Message-ID: <20071023.211556.38711526.davem@davemloft.net>
References: <471CC196.50607@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752016AbXJXEQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:16:12 -0400
In-Reply-To: <471CC196.50607@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 22 Oct 2007 19:28:22 +0400

> Instead of ugly extern not-existing function.

I can take credit for this turd.  Hey, it was the accepted way to do
compile time assertions at the time :-)

> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied!
