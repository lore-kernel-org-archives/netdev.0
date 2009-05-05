From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc911x: add power management functions
Date: Mon, 04 May 2009 21:32:31 -0700 (PDT)
Message-ID: <20090504.213231.70907223.davem@davemloft.net>
References: <1241457122-28161-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: daniel@caiaq.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561AbZEEEcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 00:32:36 -0400
In-Reply-To: <1241457122-28161-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@caiaq.de>
Date: Mon,  4 May 2009 19:12:02 +0200

> This adds a power management implementation for smsc911x.c which assumes
> the chips remains powered during suspend. The device is put in its D1
> power saving mode.
> 
> Cc: Steve Glendinning <steve.glendinning@smsc.com>
> Signed-off-by: Daniel Mack <daniel@caiaq.de>

Steve, is this OK?
