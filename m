From: Ben Greear <greearb@candelatech.com>
Subject: Re: Performance degradation on 2.6.25 kernels for http servers
Date: Wed, 23 Jul 2008 14:22:58 -0700
Message-ID: <4887A132.7010407@candelatech.com>
References: <4887968A.10308@candelatech.com> <379e30200807231420n676323a2h6fd760af50f7437f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Tobias Koeck <tobias.koeck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39768 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbYGWVXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:23:08 -0400
In-Reply-To: <379e30200807231420n676323a2h6fd760af50f7437f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Koeck wrote:
> Do you have the same configuration?

I'm not sure I understand the question.

We were booting into one kernel, running the test, and
then rebooting with a different kernel.  There were no other
changes to any config files or settings that I am aware of.

I'll try a git-bisect when I get a chance...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

