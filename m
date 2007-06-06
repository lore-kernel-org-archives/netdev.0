From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:48:59 -0700
Message-ID: <466747EB.5020101@hp.com>
References: <1181082517.4062.31.camel@localhost>	<4666CEB7.6030804@trash.net> <1181168020.4064.46.camel@localhost>	<20070606.153530.48530367.davem@davemloft.net> <1181172766.4064.83.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:42794 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407AbXFFXtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 19:49:03 -0400
In-Reply-To: <1181172766.4064.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  > RX queues - yes, I can see;  TX queues, it doesnt make sense to put
> different rings on different CPUs.

To what extent might that preclude some cachelines bouncing hither and 
yon between the CPUs?

rick jones

