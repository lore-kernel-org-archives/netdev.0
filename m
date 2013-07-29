From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Mon, 29 Jul 2013 01:46:43 -0700 (PDT)
Message-ID: <20130729.014643.2227589840281609643.davem@davemloft.net>
References: <1375063735.32309.32.camel@jtkirshe-mobl>
	<20130729.003405.2285412976756507988.davem@davemloft.net>
	<1375086885.32309.39.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab3G2Iqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 04:46:46 -0400
In-Reply-To: <1375086885.32309.39.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 29 Jul 2013 01:34:45 -0700

> On Mon, 2013-07-29 at 00:34 -0700, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Sun, 28 Jul 2013 19:08:55 -0700
>> 
>> > When will your kernel.org net-next be updated?  I ask because I have a
>> > series for ixgbe I am putting together and wanted to make sure it is
>> > against the latest net-next.
>> 
>> Are you asking when I will next merge 'net' into 'net-next'?  If so,
>> I'll likely do it some time tomorrow.
> 
> I am not worried about that.  I just cloned your net-next tree and did
> not see your pull of my net-next tree which had the e100 and e1000e
> patches.  I am working on creating another series against net-next and
> the tip on kernel.org is:
> 
> commit 9d4a0314642918cbda9ed4012df51e8df608fce6
> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date:   Fri Jul 26 17:05:16 2013 +0200
> 
>     ipv4, ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL
> 
> which is several days old.  So I was not sure if I just make my series
> against my net-next tip.

Weird, it should have all of your changes.

Tip is currently:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=fe6f700d6cbb7e8a61711e325f53d9c9e0a42a4c

net/mlx4_core: Respond to operation request by firmware
