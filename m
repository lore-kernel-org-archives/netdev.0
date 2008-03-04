From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11][NETNS][IPV6] rt6_stats - make the stats per
 network namespace
Date: Mon, 03 Mar 2008 23:34:30 -0800 (PST)
Message-ID: <20080303.233430.199177100.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094243.621444844@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761538AbYCDHeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:34:31 -0500
In-Reply-To: <20080302094243.621444844@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:31 +0100

> The rt6_stats is now per namespace with this patch. It is
> allocated when a network namespace is created and freed
> when the network namespace exits and references are relative
> to the network namespace.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Also applied, thanks a lot guys!
