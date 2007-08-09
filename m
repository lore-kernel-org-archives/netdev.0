From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Wed, 08 Aug 2007 21:35:42 -0700 (PDT)
Message-ID: <20070808.213542.32177892.davem@davemloft.net>
References: <1186491155.5163.68.camel@localhost>
	<20070807.175920.15265201.davem@davemloft.net>
	<1186575059.5171.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, rusty@rustcorp.com.au
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750867AbXHIEfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 00:35:42 -0400
In-Reply-To: <1186575059.5171.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 08 Aug 2007 08:10:59 -0400

> Its overdue - just hasnt been anybody who has raised their hands
> to do it. Stephen did at one point. 
> Theres a lot of nice insights in that doc that will be nice to inherit.
> Theres also a nice state machine diagram in 
> http://www.kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf
> that will be very useful to capture in whatever new doc.

Stephen said he would find time to work on this, so what I'll
do is yank the documentation file in my napi_struct changeset
and he can crib content from the old file and your UKUUG2005
slides.
