From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Wed, 25 Jul 2007 17:28:13 -0700 (PDT)
Message-ID: <20070725.172813.03082027.davem@davemloft.net>
References: <200707201741.45079.ossthema@de.ibm.com>
	<46A785C2.9090708@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54994
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751591AbXGZA2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:28:14 -0400
In-Reply-To: <46A785C2.9090708@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 25 Jul 2007 13:17:54 -0400

> I've ported myri10ge to use the new LRO interface.  I have attached a
> preliminary patch to myri10ge.  I'm very pleased to note that the
> performance is on-par with my own LRO used by our out-of-tree driver.
> (except when using mixed MTUS, see performance data below).

Thanks for posting this port and feedback on the generic LRO
code.
