From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 7 Sep 2009 09:46:21 +0000
Message-ID: <20090907094621.GB5966@ff.dom.local>
References: <20090907.015039.154939751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44584 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbZIGJqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 05:46:24 -0400
Received: by bwz19 with SMTP id 19so1455938bwz.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 02:46:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090907.015039.154939751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-09-2009 10:50, David Miller wrote:
> I gave these patches a very basic bashing with NIU, and it
> seems to work from what I've tried.
> 
> I know that Jarek has expressed some questions about the callback
> scheme used by the new mq classful qdisc, as well as some other
> issues, but we can refine this using followon patches.
> 
> For now I'm pushing this out so that it gets wider testing.

Sure, it should make the further discussion easier (at least until
a new backward compatibilty starts to matter ;-).

Thanks,
Jarek P.
