From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Does Realtek RTL8110S and RTL8100C work ?
Date: Sat, 27 Mar 2010 15:12:24 +0100
Message-ID: <4BAE1248.70201@computer.org>
References: <hoab2m$kc0$1@dough.gmane.org> <4BABC170.7080008@computer.org> <hoiqcr$dhl$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:16639 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753327Ab0C0OMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 10:12:43 -0400
In-Reply-To: <hoiqcr$dhl$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann wrote:
> Thanks for you answer Jan,
> 
> do you know the developer e-mail adress?
> So 1000Mbit/s is not possible at the moment, but does it work stable?
> 
> regards Markus

Markus,

You misunderstood. The first of the interfaces I listed is operating at 1Gbit/s; the second is only operating at 100Mbit/s because the device it is connected to (on the other end of the Ethernet cable) is not capable of anything faster.

I have no reliability issues with these network interfaces. Note though that my mainboard is quite low-end (Via C7 1.5GHz), so that the network interfaces never really get stressed.

Jan


