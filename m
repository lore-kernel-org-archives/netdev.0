From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/11][NETNS][IPV6] ip6_fib - dynamically allocate the
 fib tables
Date: Mon, 03 Mar 2008 23:25:03 -0800 (PST)
Message-ID: <20080303.232503.76180155.davem@davemloft.net>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
	<20080302094118.816272054@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60778
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751413AbYCDHZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:25:04 -0500
In-Reply-To: <20080302094118.816272054@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Sun, 02 Mar 2008 10:37:21 +0100

> This patch changes the fib6 tables to be dynamically allocated.
> That provides the ability to make several instances of them when
> a new network namespace is created.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied.
