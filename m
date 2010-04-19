From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Mon, 19 Apr 2010 13:23:18 -0700 (PDT)
Message-ID: <20100419.132318.192086187.davem@davemloft.net>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	<1271520633.16881.4754.camel@edumazet-laptop>
	<20100419.130905.210660275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751078Ab0DSUXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 16:23:16 -0400
In-Reply-To: <20100419.130905.210660275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Apr 2010 13:09:05 -0700 (PDT)

> net-next-2.6 + Eric's port hashing patch, rps_cpus="ffffffff,ffffffff,ffffffff,ffffffff"
> 
> tbench 64: Throughput 1593.13 MB/sec 64 procs
> tbench 128: Throughput 2367.27 MB/sec 128 procs

Eric, I think there is agreement that your patch is not a bad idea.

Your original posting had whitespace damange in the patch plus I want
to see a proper commit message and signoff, so could you please submit
this formally?

Thanks!
