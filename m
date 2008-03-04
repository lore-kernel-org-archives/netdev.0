From: David Miller <davem@davemloft.net>
Subject: Re: [patch 10/11][NETNS][IPV6] rt6_stats - dynamically allocate
 the routes statistics
Date: Mon, 03 Mar 2008 23:33:49 -0800 (PST)
Message-ID: <20080303.233349.39514453.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094239.479993746@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753077AbYCDHdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:33:50 -0500
In-Reply-To: <20080302094239.479993746@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:30 +0100

> This patch allocates the rt6_stats struct dynamically when
> the fib6 is initialized. That provides the ability to create
> several instances of this structure for the network namespaces.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
