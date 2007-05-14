From: David Miller <davem@davemloft.net>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 02:18:31 -0700 (PDT)
Message-ID: <20070514.021831.68041288.davem@davemloft.net>
References: <20070514060700.GA1000@ff.dom.local>
	<20070513.233937.99203647.davem@davemloft.net>
	<20070514072845.GA2081@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754075AbXENJSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 05:18:40 -0400
In-Reply-To: <20070514072845.GA2081@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 14 May 2007 09:28:45 +0200

> Yes, this is very good idea, and I wonder, why you didn't try
> this yourself (after my "ignore").

Because you are a skilled programmer and you might find some
flaw in my suggestion :-)
