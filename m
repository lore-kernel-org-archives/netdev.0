From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 20 Sep 2007 13:43:12 +0200
Message-ID: <46F25CD0.7010702@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100438.18347.2@janus.isnogud.escape.de>	<46EFD33D.8030905@trash.net> <ygffy1bzn4c.fsf@janus.isnogud.escape.de>	<46F0DD8E.8070808@trash.net> <ygfy7f1g1l0.fsf@janus.isnogud.escape.de>	<46F24C8D.2020804@trash.net> <ygftzppfuab.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35650 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbXITLug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 07:50:36 -0400
In-Reply-To: <ygftzppfuab.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> I will post our updated code again, probably today.  The issues still
> left are
> 
> * module parameter for loopback, but we want to keep that.

No objections.

> * configure option for allowing normal users access to raw and bcm CAN
>   sockets.  I'll check how easily an (embedded) system can be set up
>   to run relevant/all processes with the CAP_NEW_RAW capability.  I
>   would like to kill that configure option.

Great.

> * seq_files for proc fs.  On my TODO list.

Sounds good, thanks.
