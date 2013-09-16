From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH stable] ipv6: restrict neighbor entry creation to output
 flow
Date: Mon, 16 Sep 2013 23:21:05 +0200
Message-ID: <20130916212105.GA1401@minipsycho.orion>
References: <20130814150054.GB2723@order.stressinduktion.org>
 <20130815.155454.417440388188230172.davem@davemloft.net>
 <20130909121719.GA3269@minipsycho.brq.redhat.com>
 <20130909.132900.704139320855868470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, mleitner@redhat.com,
	netdev@vger.kernel.org, dbanerje@akamai.com,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:38811 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab3IPVVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 17:21:09 -0400
Received: by mail-ea0-f174.google.com with SMTP id z15so2306453ead.5
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 14:21:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130909.132900.704139320855868470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 09, 2013 at 07:29:00PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 9 Sep 2013 14:17:19 +0200
>
>> When do you plan to push this to stable maintainers?
>
>Jiri, it's in the -stable queue and that means I will send it at an
>appropriate time.
>
>I'm working on a submission at the moment, but every extra query like
>your's that I have to answer takes up time I could be spending on it.

I'm sorry Dave. I'm just worried. I don't want this patch to get lost.
I expected this patch to be part of:
http://git.kernel.org/cgit/linux/kernel/git/bwh/linux-3.2.y-queue.git/commit/?id=dadcb7672a124159630f1f756dea8323bc4976bd

But it is not there.

I'm sorry again :/

Jiri
