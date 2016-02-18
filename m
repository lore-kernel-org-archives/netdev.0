From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/13] rocker: do world split
Date: Wed, 17 Feb 2016 23:08:59 -0500 (EST)
Message-ID: <20160217.230859.97288324920773592.davem@davemloft.net>
References: <1455632091-10716-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423667AbcBREJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 23:09:06 -0500
In-Reply-To: <1455632091-10716-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 16 Feb 2016 15:14:38 +0100

> This patchset allows new rocker worlds to be easily added in future.
> Two new worlds are now under development: P4 and eBPF.
> 
> The main part of the patchset is the OF-DPA carve-out. It resuts in OF-DPA
> specific file. Clean cut.
> 
> Note this patchset is based on my original attempt in October 2015.
> I had to rebase, included all suggestions and did lot of small changes.
> Main change to go with all-port-one-world approach. Port world is set according
> to what is setup in HW. Not possible to change worlds from driver.
> ---
> v1->v2:
>   patch 12/13:
>   - split port_init into pre-init and init

Series applied, thanks Jiri.
