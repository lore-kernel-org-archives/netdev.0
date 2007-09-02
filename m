From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: 02 Sep 2007 09:30:57 +0200
Message-ID: <p73d4x1bk26.fsf@bingen.suse.de>
References: <1187914105.26866.41.camel@bagoas.tjworld.net>
	<20070824071530.GB26447@xi.wantstofly.org>
	<20070824084048.GA8346@ms2.inr.ac.ru>
	<1187947887.6976.18.camel@bagoas.tjworld.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: TJ <linux@tjworld.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:37100 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840AbXIBHa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 03:30:58 -0400
In-Reply-To: <1187947887.6976.18.camel@bagoas.tjworld.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TJ <linux@tjworld.net> writes:
> 
> Therefore, anyone deploying apache web servers in a web-farm behind the
> Juniper DX load-balanders and using TCP multiplexing (for which they pay
> a hefty licence fee!) 

If they ask for that much money they can surely fix it to work
properly too? 

-Andi
