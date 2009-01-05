From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/6] qeth: exploit source MAC address for inbound
 layer3 packets
Date: Sun, 04 Jan 2009 17:36:46 -0800 (PST)
Message-ID: <20090104.173646.267979540.davem@davemloft.net>
References: <20090102150139.830998000@de.ibm.com>
	<20090102150253.923245000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60025
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbZAEBgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:36:42 -0500
In-Reply-To: <20090102150253.923245000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 02 Jan 2009 16:01:41 +0100

> OSA-devices operating in layer3 mode offer adding of the source MAC
> address to the QDIO header of inbound packets. The qeth driver can
> exploit this functionality to replace FAKELL-entries in the ethernet
> header of received packets.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
