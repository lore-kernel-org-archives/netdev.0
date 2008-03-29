From: Jeff Garzik <jeff@garzik.org>
Subject: Re: tulip driver receive but not send 2.6.25-rc6-git7
Date: Fri, 28 Mar 2008 21:34:44 -0400
Message-ID: <47ED9CB4.7010603@garzik.org>
References: <200803281828.39948.gustavo@compunauta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>,
	Grant Grundler <grundler@parisc-linux.org>
To: =?ISO-8859-1?Q?Gustavo_Guillermo_P=E9rez?= <gustavo@compunauta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755677AbYC2Beq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:34:46 -0400
In-Reply-To: <200803281828.39948.gustavo@compunauta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gustavo Guillermo P=E9rez wrote:
> I'm putting all wires on the same swirch for testing.
> eth0 is a sis embedded card (good one).
> dealing with dhcp I see that request arrives to the board but the off=
ers never=20
> appears on client. system clean no iptables rules, just dhcpd.

> I'm gonna try with rc7-git4 and 2.6.24

Please do.

Also, try the 'dmfe' driver, as it was written specifically for these c=
hips.

	Jeff


