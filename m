From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 08 Nov 2006 20:44:13 +0100
Message-ID: <1163015053.3138.378.camel@laptopd505.fenrus.org>
References: <1162924354.10806.172.camel@localhost.localdomain>
	 <1163001318.3138.346.camel@laptopd505.fenrus.org>
	 <20061108162955.GA4364@suse.de>
	 <1163011132.10806.189.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Olaf Kirch <okir@suse.de>, linux-kernel@vger.kernel.org,
	davem@sunset.davemloft.net, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:24722 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1422691AbWKHToT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 14:44:19 -0500
To: tim.c.chen@linux.intel.com
In-Reply-To: <1163011132.10806.189.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> However, Volanomark is just a benchmark to alert us to changes.  
> If in real applications with small segment, this patch is 
> needed to fix congestion window adjustment as Dave pointed 
> out, and impact on bandwidth not as important, so be it.
> 
> Tim

if we can get the best of both worlds (by having the extra acks drop on
congestion) it's of course nicer ;)

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

