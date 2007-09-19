From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 16:53:23 -0700 (PDT)
Message-ID: <20070919.165323.127197853.davem@davemloft.net>
References: <20070918.151528.84360712.davem@davemloft.net>
	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
	<46F1AEC7.8090604@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com, jeff@garzik.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54312
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753052AbXISXxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:53:24 -0400
In-Reply-To: <46F1AEC7.8090604@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 19 Sep 2007 16:20:39 -0700

> so why "niu?"  To what does niu translate anyway?

Network Interface Unit.  This is what the Niagara-2 programmers manual
refers to the chip as.

I try to name the files for most drivers I write as a 2 or 3 letter
acronyms, it looks so much better than the usual verbose names.  It's
very unix.
