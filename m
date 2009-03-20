From: David Miller <davem@davemloft.net>
Subject: Re: e1000 under VMware doesn't work since 2.6.27.16 - BISECTED
Date: Fri, 20 Mar 2009 15:57:39 -0700 (PDT)
Message-ID: <20090320.155739.93629479.davem@davemloft.net>
References: <49C3C726.4000405@bcsoft.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drifter@bcsoft.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753890AbZCTW5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 18:57:51 -0400
In-Reply-To: <49C3C726.4000405@bcsoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Stroebel <drifter@bcsoft.de>
Date: Fri, 20 Mar 2009 17:41:10 +0100

> 		Hello,
> 
> we're using virtual machines under VMware with the e1000 emulated
> network card.

Sounds like vmware doesn't emulate the e1000 accurately enough.
