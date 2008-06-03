From: David Miller <davem@davemloft.net>
Subject: Re: [NET] route: Mark unused route cache flags as such.
Date: Tue, 03 Jun 2008 16:36:09 -0700 (PDT)
Message-ID: <20080603.163609.123753451.davem@davemloft.net>
References: <20080526112858.GW20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49527
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751930AbYFCXgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:36:09 -0400
In-Reply-To: <20080526112858.GW20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 26 May 2008 13:28:59 +0200

> Also removes an obsolete check for the unused flag RTCF_MASQ.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
