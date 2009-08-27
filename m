From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/5] s390: qeth patches for 2.6.32
Date: Wed, 26 Aug 2009 17:35:02 -0700 (PDT)
Message-ID: <20090826.173502.214522263.davem@davemloft.net>
References: <20090826120105.727838000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753608AbZH0Aet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 20:34:49 -0400
In-Reply-To: <20090826120105.727838000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 26 Aug 2009 14:01:05 +0200

> here are a couple of qeth patches for 2.6.32 (net-next).
> 
> shortlog:
> Klaus-Dieter Wacker (3)
> qeth: HiperSockets SIGA retry support on CC=2.
> qeth: Cleanup for cast-type determination.
> qeth: display service_level info only when valid.
> 
> Ursula Braun (1)
> qeth: display "undefined" value of sysfs-attribute "layer2"
> 
> Frank Blaschka (1)
> qeth: scheduling while atomic during ifconfig online sequence

Looks good, all applied to net-next-2.6, thanks!
