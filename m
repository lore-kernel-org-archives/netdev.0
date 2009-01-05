From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/6] qeth: get rid of extra argument after printk to
 dev_* conversion
Date: Sun, 04 Jan 2009 17:37:17 -0800 (PST)
Message-ID: <20090104.173717.124451945.davem@davemloft.net>
References: <20090102150139.830998000@de.ibm.com>
	<20090102150256.663537000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, heiko.carstens@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbZAEBhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 20:37:14 -0500
In-Reply-To: <20090102150256.663537000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 02 Jan 2009 16:01:45 +0100

> drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_setadapter_parms':
> drivers/s390/net/qeth_l3_main.c:1049: warning: too many arguments for format
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Also applied, thanks.
