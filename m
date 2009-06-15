From: Paul Smith <paul@mad-scientist.net>
Subject: Any implementation of NETPOLL for bonding?
Date: Mon, 15 Jun 2009 17:26:02 -0400
Message-ID: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:59750 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754825AbZFOVlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 17:41:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wanted to attach to my kernel with KGDBOE but failed because the
bonding driver doesn't support NETPOLL, and the only network access to
the system is over a bonded interface.

This is a big bummer for me :-).

Is there any possibility of NETPOLL being supported in the bonding
driver?  I found a very old patch set from Jeff Moyer (circa 2005)
adding NETPOLL support to the bonding driver but as far as I can
determine it's not present in current kernels.

Anything ever happen with this since then?

Cheers!

