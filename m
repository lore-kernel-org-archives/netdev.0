From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:11:29 -0700
Message-ID: <46D5EF11.3020803@hp.com>
References: <200708292052.NAA21975@tardy.cup.hp.com> <46D5E191.6070401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:43247 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757407AbXH2WLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:11:51 -0400
In-Reply-To: <46D5E191.6070401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I am sure you can use CTL_UNNUMBERED instead of adding yet another 
> sysctl value, as advised in include/linux/sysctl.h
> 
> **  For new interfaces unless you really need a binary number
> **  please use CTL_UNNUMBERED.

fair enough.  i was just repeating past behaviour :)

rick jones
