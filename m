From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 02:08:37 -0700 (PDT)
Message-ID: <20090422.020837.58106317.davem@davemloft.net>
References: <20090421230358.GA13660@hmsreliant.think-freely.org>
	<20090422011214.GA18856@localhost.localdomain>
	<49EEA7E3.3080507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752854AbZDVJIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:08:45 -0400
In-Reply-To: <49EEA7E3.3080507@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 22 Apr 2009 07:15:15 +0200

> Also, it seems some RFC4293 items are already handled, since commit d831666e
> from Mitsuru Chinen. Check net/ipv4/proc.c, line 114
> 
> /* Following RFC4293 items are displayed in /proc/net/netstat */
> static const struct snmp_mib snmp4_ipextstats_list[] = {

It is my understanding that after Mitsuru's patch, all RFC4293
values are available in one way or another.
