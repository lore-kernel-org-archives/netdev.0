From: Patrick McHardy <kaber@trash.net>
Subject: Re: net-sched 04/05: sch_htb: move hash and sibling list removal
 to htb_delete
Date: Thu, 03 Jul 2008 13:53:48 +0200
Message-ID: <486CBDCC.2050906@trash.net>
References: <20080702081559.GA2764@ami.dom.local> <486B543A.8040608@trash.net> <20080702211402.GA2476@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34690 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYGCMFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:05:01 -0400
In-Reply-To: <20080702211402.GA2476@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> A tiny update below...
>
> On Wed, Jul 02, 2008 at 12:11:06PM +0200, Patrick McHardy wrote:
> ...
>   
> I still think the patch is OK, but this one little compile warning
> (which, I guess, you've seen already...):
>
> net/sched/sch_htb.c: In function 'htb_destroy_class':
> net/sched/sch_htb.c:1215: warning: unused variable 'q'


Yes, I already fixed that.
