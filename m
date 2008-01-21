From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: post 2.6.24-rc7 regression: unregister_netdevice: waiting for eth1 to become free
Date: Mon, 21 Jan 2008 17:04:14 +0100
Message-ID: <200801211704.14909.m.kozlowski@tuxland.pl>
References: <200801210109.42153.m.kozlowski@tuxland.pl> <20080120.163241.80038143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.ambsoft.pl ([212.109.144.130]:46484 "EHLO
	orion.ambsoft.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbYAUQES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 11:04:18 -0500
In-Reply-To: <20080120.163241.80038143.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> > kernel: unregister_netdevice: waiting for eth1 to become free. Usage count = 1
> 
> Known problem:
> 
> 	http://bugzilla.kernel.org/show_bug.cgi?id=9778

Hm ... I was largely offline on weekend and did not see that. Is there any way
I can subscribe 'somewhere' to get notified about any new entry in kernel bugzilla?

Regards,

	Mariusz
