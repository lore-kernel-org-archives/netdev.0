From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Configuring traffic classes via new hardware
 offload mechanism in tc/mqprio
Date: Tue, 11 Jul 2017 17:36:51 -0700 (PDT)
Message-ID: <20170711.173651.744697529471539908.davem@davemloft.net>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
        <20170711.072635.185388451319287053.davem@davemloft.net>
        <1499818697.4698.12.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amritha.nambiar@intel.com, intel-wired-lan@lists.osuosl.org,
        alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755958AbdGLAgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 20:36:52 -0400
In-Reply-To: <1499818697.4698.12.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Jul 2017 17:18:17 -0700

> On Tue, 2017-07-11 at 07:26 -0700, David Miller wrote:
>> From: Amritha Nambiar <amritha.nambiar@intel.com>
>> Date: Tue, 11 Jul 2017 03:18:30 -0700
>> 
>> > The following series introduces a new hardware offload mode in
>> > tc/mqprio where the TCs, the queue configurations and
>> > bandwidth rate limits are offloaded to the hardware.
>> 
>> net-next is closed, please resubmit this when net-next opens
>> again:
>> 
>> 	http://vger.kernel.org/~davem/net-next.html
>> 
>> Thank you.
> 
> Dave, this is gonna come through my tree.  Amritha is looking for
> community feedback, while we have this under validation.  Sorry for the
> confusion.

One way to deal with this is to say something like:

	[PATCH net-next RFC]

in the subject lines instead of just:

	[PATCH net-next]
