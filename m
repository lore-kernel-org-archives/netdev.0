From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] solos-pci: Fix regression introduced by newest
 firmware
Date: Sun, 20 Mar 2011 23:04:08 -0700 (PDT)
Message-ID: <20110320.230408.112594622.davem@davemloft.net>
References: <1300676496.26693.318.camel@localhost>
	<20110320.215704.193716335.davem@davemloft.net>
	<4D86E89B.1060905@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751416Ab1CUGDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 02:03:31 -0400
In-Reply-To: <4D86E89B.1060905@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Date: Sun, 20 Mar 2011 22:56:43 -0700

> It's not clear that dropping all VCs abruptly when carrier flapped was
> ever the right thing to do.

So you've tested your change with the older firmware present?
