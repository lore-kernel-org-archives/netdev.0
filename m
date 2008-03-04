From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/11][NETNS][IPV6] ip6_fib - fib6_clean_all handle
 several network namespaces
Date: Mon, 03 Mar 2008 23:27:15 -0800 (PST)
Message-ID: <20080303.232715.52497048.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094144.746906445@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751210AbYCDH1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:27:16 -0500
In-Reply-To: <20080302094144.746906445@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:23 +0100

> The function fib6_clean_all takes the network namespace
> as parameter. That allows to flush the routes related to 
> a specific network namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
