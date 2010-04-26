From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Mon, 26 Apr 2010 13:53:05 -0700 (PDT)
Message-ID: <20100426.135305.15235166.davem@davemloft.net>
References: <4BD5F553.6020006@hp.com>
	<20100426.134051.232750473.davem@davemloft.net>
	<4BD5FC16.4070402@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751157Ab0DZUw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 16:52:59 -0400
In-Reply-To: <4BD5FC16.4070402@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 26 Apr 2010 13:48:22 -0700

> Do not confuse explanation with endorsement.

Ok, fair enough.

But I don't see even the "other perspective" argument being even
valid.  Big shops still use UDP and it has to scale.

Or have they made multicast magically start working with TCP so
they can us it to do trades on the NASDAQ?
