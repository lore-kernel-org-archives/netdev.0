From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: add missing last_rx setting
Date: Thu, 04 Jun 2009 15:42:04 -0700 (PDT)
Message-ID: <20090604.154204.163892378.davem@davemloft.net>
References: <20090604155019.6660.33231.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbZFDWmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 18:42:03 -0400
In-Reply-To: <20090604155019.6660.33231.stgit@Programuotojas>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Thu, 04 Jun 2009 18:50:23 +0300

> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

The core networking does this now for the drivers, they
don't need to do it themselves any longer.

Your patch is not correct.
