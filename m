From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/2] core: Factor out flow calculation from
 get_rps_cpu
Date: Tue, 17 Aug 2010 01:50:09 -0700 (PDT)
Message-ID: <20100817.015009.102566951.davem@davemloft.net>
References: <20100804161552.3814.56839.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, mst@redhat.com, netdev@vger.kernel.org,
	xiaosuo@gmail.com, bhutchings@solarflare.com, therbert@google.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756871Ab0HQItv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 04:49:51 -0400
In-Reply-To: <20100804161552.3814.56839.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 04 Aug 2010 21:45:52 +0530

> Factor out flow calculation code from get_rps_cpu, since other
> functions can use the same code.

Applied.
