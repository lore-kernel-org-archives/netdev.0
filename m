From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: correct a comment for the final #endif
Date: Wed, 27 May 2009 23:33:44 -0700 (PDT)
Message-ID: <20090527.233344.74118227.davem@davemloft.net>
References: <20090527140153.GE1652@psychotron.englab.brq.redhat.com>
	<20090527.154911.39711918.davem@davemloft.net>
	<20090528054712.GA20533@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752076AbZE1Gdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 02:33:45 -0400
In-Reply-To: <20090528054712.GA20533@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 28 May 2009 07:47:13 +0200

> Btw how do you choose what patch to apply to what tree?

It depends upon where we are in the development cycle and the
nature of your patch.

Right now we're only applying the most critical bug fixes
to net-2.6, anything else goes to net-next-2.6
