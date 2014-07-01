From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 0/3] Optimizing pktgen for single CPU
 performance
Date: Tue, 01 Jul 2014 15:51:19 -0700 (PDT)
Message-ID: <20140701.155119.623382273728705163.davem@davemloft.net>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140626111549.23576.90201.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, fw@strlen.de,
	hannes@stressinduktion.org, tgraf@suug.ch, eric.dumazet@gmail.com,
	zoltan.kiss@citrix.com, alexander.h.duyck@intel.com,
	jeffrey.t.kirsher@intel.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030302AbaGAWvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 18:51:23 -0400
In-Reply-To: <20140626111549.23576.90201.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 26 Jun 2014 13:16:17 +0200

> This series focus on optimizing "pktgen" for single CPU performance.
> 
> V2-series:
>  - Removed some patches
>  - Doc real reason for TX ring buffer filling up

Looks great, series applied, thanks.
