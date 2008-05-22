From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] WAN: protect Cisco HDLC state changes with a spinlock.
Date: Thu, 22 May 2008 22:33:18 +0200
Message-ID: <m3zlqi6pv5.fsf@maximus.localdomain>
References: <m3od72gqxf.fsf@maximus.localdomain> <48354906.2010409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:43146 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886AbYEVUdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 16:33:22 -0400
In-Reply-To: <48354906.2010409@garzik.org> (Jeff Garzik's message of "Thu\, 22 May 2008 06\:20\:54 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

>> WAN: protect Cisco HDLC state changes with a spinlock.
>>     Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>
> applied

Thanks Jeff, David.
--=20
Krzysztof Halasa
