From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] 2.6.24-rc1 remove architecture warning compiling fealnx
 on ia64
Date: Fri, 26 Oct 2007 14:38:54 -0700
Message-ID: <47225E6E.70400@hp.com>
References: <200710262104.OAA14012@tardy.cup.hp.com> <47225BAD.4080801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:48991 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbXJZVi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 17:38:59 -0400
In-Reply-To: <47225BAD.4080801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Overall that poor driver is more than a little bit ugly :)

Well, given some of the code I've put into netperf over the years I wasn't going 
to be the first to cast a stone :) but I won't disagree with the assesment :)

> Looking at the large chain of highly-similar values, I would tend to 
> prefer the attached patch...

That achieves my desired end result of no warning while compiling on ia64 so I'm 
happy with it.  I suspect that may also get rid of a warning on parisc so I 
should be doubly pleased :)

rick jones

