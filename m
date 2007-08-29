From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:32:38 -0700
Message-ID: <46D5F406.3040307@hp.com>
References: <200708292052.NAA21975@tardy.cup.hp.com>	<5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>	<20070829.144656.104048365.davem@davemloft.net> <20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:59044 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbXH2WdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:33:21 -0400
In-Reply-To: <20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From what I've seen thusfar, the issue isn't so much actual loss, but 
very variable RTTs leading to spurrious RTOs.

rick jones
