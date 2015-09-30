From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next:master 414/428] net/ipv6/tcp_ipv6.c:930: warning:
 passing argument 1 of 'tcp_v6_md5_do_lookup' discards qualifiers from
 pointer target type
Date: Tue, 29 Sep 2015 21:19:00 -0700
Message-ID: <1443586740.32531.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201509301242.V51qs4FL%fengguang.wu@intel.com>
	 <1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150929.211243.946334552303109593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, edumazet@google.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34251 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbI3ETD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:19:03 -0400
Received: by padhy16 with SMTP id hy16so26823129pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 21:19:02 -0700 (PDT)
In-Reply-To: <20150929.211243.946334552303109593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-29 at 21:12 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 29 Sep 2015 21:10:28 -0700
> 
> > Thanks, probably a matter of applying this patch.
> 
> Looks obvious enough, please submit this formally, thanks.

Sure ! I am compiling ;)
