From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Wed, 23 Sep 2009 17:02:47 -0700
Message-ID: <4ABAB727.2020507@hp.com>
References: <4ABAA2D0.4030608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:43546 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbZIXACp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 20:02:45 -0400
In-Reply-To: <4ABAA2D0.4030608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> When LRO is enabled, the received packet and byte counters represent the
> LRO'd packets, not the packets/bytes on the wire. 

When LRO is enabled, are all the bytes on the wire actually transferred into the 
host?

rick jones
