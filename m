From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bpf: do not use reciprocal divide
Date: Fri, 17 Jan 2014 18:56:00 -0800 (PST)
Message-ID: <20140117.185600.1405505573912550580.davem@davemloft.net>
References: <1389797407.31367.340.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140115.170230.640619926492650356.davem@davemloft.net>
	<20140117085916.GA4208@osiris>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, schwidefsky@de.ibm.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	dborkman@redhat.com, darkjames-ws@darkjames.pl, mgherzan@gmail.com,
	rmk+kernel@arm.linux.org.uk, matt@ozlabs.org
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbaARC4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:56:01 -0500
In-Reply-To: <20140117085916.GA4208@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 17 Jan 2014 09:59:16 +0100

> Could you please also apply the patch below to your tree? It would only
> generate a merge conflict, that would need fixing, if it would sit in the
> s390 tree.

Applied and I queued it up for -stable so I can combine it with
Eric's original change when I submit it to -stable.
