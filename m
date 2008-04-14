From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 11:26:24 +0200
Message-ID: <87d4oswzwf.fsf@basil.nowhere.org>
References: <47FEADCB.7070104@rtr.ca>
	<20080413121831.d89dd424.akpm@linux-foundation.org>
	<20080413202118.GA29658@2ka.mipt.ru> <200804132233.50491.rjw@sisk.pl>
	<20080413205406.GA9190@2ka.mipt.ru> <48028830.6020703@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out01.alice-dsl.net ([88.44.60.11]:17485 "EHLO
	smtp-out01.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbYDNJ1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 05:27:17 -0400
In-Reply-To: <48028830.6020703@earthlink.net> (Stephen Clark's message of "Sun, 13 Apr 2008 18:24:48 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Clark <sclark46@earthlink.net> writes:

> I been a linux user and have followed the LKML for a
> number of years and have yet to see
> any test plans for any submitted patches.

You haven't looked closely then. While it's not very common there 
is a non trivial number of patches who describe how they got tested
in the patch description.

-Andi
