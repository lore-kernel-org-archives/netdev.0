From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 15:35:25 +0100
Message-ID: <45C0A92D.3000206@trash.net>
References: <20070131075348.GA1857@ff.dom.local> <45C09E0B.6020107@trash.net> <20070131143106.GA3521@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63492 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933304AbXAaOf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 09:35:28 -0500
In-Reply-To: <20070131143106.GA3521@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Wed, Jan 31, 2007 at 02:47:55PM +0100, Patrick McHardy wrote:
> 
>>>+static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
>>>+							struct gnet_dump *d)
>>
>>Please align with struct Qdisc.
> 
> 
> I'm not sure it's fully compliant to the CodingStyle
> text (e.g. spaces as indentation) but I'm a polite guy.


Probably not, but it stays in line with the remaining file.
