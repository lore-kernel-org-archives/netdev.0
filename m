From: David Miller <davem@davemloft.net>
Subject: Re: behavior of TSO in kernel
Date: Fri, 05 Jun 2009 18:20:38 -0700 (PDT)
Message-ID: <20090605.182038.133831345.davem@davemloft.net>
References: <340578.72366.qm@web94815.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: radhamohan_ch@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752161AbZFFBUh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 21:20:37 -0400
In-Reply-To: <340578.72366.qm@web94815.mail.in2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Radha Mohan <radhamohan_ch@yahoo.com>
Date: Fri, 5 Jun 2009 20:09:10 +0530 (IST)

> I have an ethernet driver with TSO, SG, IP_CSUM=A0features enabled. I
> am using linux-2.6.15 kernel. The MTU is set to 9014. It seems the
> driver is getting skbs of only 9014 bytes length even though the
> application is able to write some 64KB at a time.

The TSO engine of the networking has been rewritten at least
3 times since 2.6.15

You're asking us how code worked three major rewrites ago and
nobody is going to help you without some kind of paid support
contract from a Linux support vendor, sorry.
