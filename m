From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Thu, 28 Sep 2017 08:48:38 -0700 (PDT)
Message-ID: <20170928.084838.221261977944137338.davem@davemloft.net>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
        <20170926153522.31500-3-jakub.kicinski@netronome.com>
        <20170928065912.00a9b6a1@cakuba>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
        dsahern@gmail.com, oss-drivers@netronome.com
To: kubakici@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdI1Psj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:48:39 -0400
In-Reply-To: <20170928065912.00a9b6a1@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>
Date: Thu, 28 Sep 2017 06:59:12 -0700

> On Tue, 26 Sep 2017 08:35:22 -0700, Jakub Kicinski wrote:
>> Add a simple tool for querying and updating BPF objects on the system.
>> 
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> 
> Dave, I got some late review nitpicks internally which I think are
> worth addressing.  Would you mind dropping this series?  I will post v2
> with the cleanups and README included.

Sure.
