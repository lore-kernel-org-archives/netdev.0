From: Paul Smith <paul@mad-scientist.us>
Subject: Re: 2.6.27.18: bnx2/tg3: BUG: "scheduling while atomic" trying
	toifenslave a second interface to my bond
Date: Mon, 04 May 2009 20:59:40 -0400
Message-ID: <1241485181.6499.678.camel@homebase.localnet>
References: <1239657348.8944.529.camel@psmith-ubeta.netezza.com>
	 <1241397581.6499.658.camel@homebase.localnet>
	 <4086.1241463817@death.nxdomain.ibm.com>
	 <20090504.120651.32573620.davem@davemloft.net>
	 <1241476694.8305.234.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.us
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.lnh.mail.rcn.net ([207.172.157.102]:7664 "EHLO
	smtp02.lnh.mail.rcn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227AbZEEBKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 21:10:08 -0400
In-Reply-To: <1241476694.8305.234.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whew!  I was a bit worried there :-)

Can we re-queue this for 2.6.27-stable then?  I've got the patch already
building in my tree but it'd be nice to get it there by default going
forward.

Cheers!
