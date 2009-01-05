From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/6] HiperSockets mcl string conversion (pre z9 mach)
Date: Sun, 04 Jan 2009 17:36:39 -0800 (PST)
Message-ID: <20090104.173639.41208746.davem@davemloft.net>
References: <20090102150139.830998000@de.ibm.com>
	<20090102150253.149662000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kdwacker@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbZAEBgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:36:36 -0500
In-Reply-To: <20090102150253.149662000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 02 Jan 2009 16:01:40 +0100

> The pre z9 machines provide an mcl string in EBCDIC format,
> z9 or later provide string in ASCII format.
> 
> Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
