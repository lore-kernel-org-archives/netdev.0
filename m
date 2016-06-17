From: Jean He <jhe@uber.com>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Fri, 17 Jun 2016 18:52:38 +0000 (UTC)
Message-ID: <loom.20160617T204804-722@post.gmane.org>
References: <55B6E8AC.4060600@alliedtelesis.co.nz> <CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com> <55B7F202.5050503@alliedtelesis.co.nz> <20150729061148.GB18456@unicorn.suse.cz> <CALx6S36NeeBeLj_UDMMm1-ub-cPy5n7OZhqGag2rN7bcQo9kWQ@mail.gmail.com> <55B97CAC.3010004@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:42197 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbcFQS50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 14:57:26 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1bDyv6-0003r1-E6
	for netdev@vger.kernel.org; Fri, 17 Jun 2016 20:55:08 +0200
Received: from 207.231.170.7 ([207.231.170.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:55:03 +0200
Received: from jhe by 207.231.170.7 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:55:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Laing <Richard.Laing <at> alliedtelesis.co.nz> writes:

> >>> Fair enough, I will look at making it a sysctl option. I guess the
> >>> default can be the current behaviour.

> Cheers
> Richard
> 


Hi Richard,

Could you please share if this new patch for per-flow IPv4 ECMP has landed?

If so, which version should I use? 

And is there a sysctl option that we can just use to enable per-flow hashing?

Many thanks!
Jean
