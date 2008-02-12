From: fgnijuhhu guduggurehug <jsmiths1234@live.com>
Subject: RE: r8169 auto-negotiation problem
Date: Tue, 12 Feb 2008 16:44:18 +0000
Message-ID: <BAY107-W2892B3D06485CBB5AEDCC2D52B0@phx.gbl>
References: <BAY107-W4033FF1A4417D61C5177FD5310@phx.gbl>
 <20080203184525.GA12607@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s36.bay0.hotmail.com ([65.54.246.236]:24009 "EHLO
	bay0-omc3-s36.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763599AbYBLQoS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 11:44:18 -0500
In-Reply-To: <20080203184525.GA12607@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> fgnijuhhu guduggurehug  :
> [...]
>> I already posted my problem and what I did to solve it on
>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=461429.
>
> Have you tried anything more recent than a 2.6.18 based kernel ?

No, but if changes were made to the iniatialization of the chipset in the current driver (mine was 2.2LK), this might do the trick. The problem is that the error is rather erratic and unreproducible.

Anyway, how to best upgrade the kernel in debian (without problems, of course)? The problem right now is that every apt-get upgrade reverts the r8169 driver to the old one...
_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE!
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/