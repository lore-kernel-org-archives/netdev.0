From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Update SNMP basic for full IP address NAT
Date: Fri, 03 Nov 2006 11:23:44 +0100
Message-ID: <454B18B0.5000603@trash.net>
References: <3418F3471F1CA4409901547349FFAE2E05A04F70@FTRDMEL2.rd.francetelecom.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24026 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1752848AbWKCKXu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 05:23:50 -0500
To: zze-Ganesh KERDONCUFF G ext RD-MAPS-REN
	<gkerdoncuff.ext@orange-ftgroup.com>
In-Reply-To: <3418F3471F1CA4409901547349FFAE2E05A04F70@FTRDMEL2.rd.francetelecom.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zze-Ganesh KERDONCUFF G ext RD-MAPS-REN wrote:
> The algorithm now applies NAT to the complete IP address (and not only
> the first byte)
> It also recomputes the UDP checksum accordingly.

I'm not too familiar with SNMP NAT, please send this to
netfilter-devel@lists.netfilter.org so other netfilter
developers get a chance to look at it.

