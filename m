From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] remove the unused APOLLO_ELPLUS option
Date: Thu, 26 Jun 2008 03:40:29 -0400
Message-ID: <486347ED.7080108@pobox.com>
References: <20080625162454.GB10285@cs181140183.pp.htv.fi> <Pine.LNX.4.64.0806260925190.30924@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>,
	linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42489 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926AbYFZHki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 03:40:38 -0400
In-Reply-To: <Pine.LNX.4.64.0806260925190.30924@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven wrote:
> On Wed, 25 Jun 2008, Adrian Bunk wrote:
>> Looking at older kernel sources the APOLLO_ELPLUS option was added 
>> somewhere during kernel 2.1, but even kernel 2.2.0 does not contain
>> any driver that would be enabled through it...
>>
>> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
>> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> (queued for 2.6.27, unless Jeff wants it to pass via his tree?)

Your queue is fine with me...


