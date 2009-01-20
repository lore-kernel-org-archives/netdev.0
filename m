From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments in non-debug build
Date: Mon, 19 Jan 2009 21:11:48 -0800
Message-ID: <200901192111.48432.david-b@pacbell.net>
References: <20090119.171200.235073814.davem@davemloft.net> <200901191804.09004.david-b@pacbell.net> <20090119.200802.48047345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	ian.saturley@smsc.com, jeff@garzik.org, jussi.kivilinna@mbnet.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp125.sbc.mail.sp1.yahoo.com ([69.147.65.184]:28423 "HELO
	smtp125.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757323AbZATFLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 00:11:50 -0500
In-Reply-To: <20090119.200802.48047345.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 January 2009, David Miller wrote:
> > Maybe, but that's after all part of why we want this kind
> > of patch merged ... after the first gremlines are fixed!
> 
> When you submit a change like this that can have
> potential warning and build failure effects across
> the entire tree, the onus is on you to do an
> allmodconfig sanity check build or similar and
> add any necessary fixes to your change.

It's actually Steve's patch ... Steve?


