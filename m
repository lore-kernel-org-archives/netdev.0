From: David Miller <davem@davemloft.net>
Subject: Re: ieee802154: Source addr fix for dgram and some small at86rf230
 driver enhancements
Date: Wed, 27 Mar 2013 00:53:18 -0400 (EDT)
Message-ID: <20130327.005318.1058473513349640907.davem@davemloft.net>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	alan@signal11.us
To: stefan@datenfreihafen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab3C0ExV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 00:53:21 -0400
In-Reply-To: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Schmidt <stefan@datenfreihafen.org>
Date: Tue, 26 Mar 2013 22:41:28 +0000

> Hello.
> 
> Second version. Changes since version 1:
> - Obey 80 chars rules
> - Switch logging mode to vdbg to avoid noise
> - Remove uneeded might_sleep()
> 
> Thanks Alan, Werner and Alex for the feedback.
> 
> I feel these are ready so I added DaveM and netdev to pick them up if they think
> the same.

All applied.
