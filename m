From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 0/3] sctp: a bunch of fixes for prsctp polices
Date: Fri, 30 Sep 2016 02:08:05 -0400 (EDT)
Message-ID: <20160930.020805.696758129244744153.davem@davemloft.net>
References: <cover.1475087147.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935666AbcI3GIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 02:08:11 -0400
In-Reply-To: <cover.1475087147.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 29 Sep 2016 02:37:25 +0800

> This patchset is to fix 2 issues for prsctp polices:
> 
>   1. patch 1 and 2 fix "netperf-Throughput_Mbps -37.2% regression" issue
>      when overloading the CPU.
> 
>   2. patch 3 fix "prsctp polices should check both sides' prsctp_capable,
>      instead of only local side".

Series applied, thanks.
