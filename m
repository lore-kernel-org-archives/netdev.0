From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 27 Apr 2006 16:49:27 -0700
Message-ID: <41b516cb0604271649o31315086ma1c82b824da263e7@mail.gmail.com>
References: <20060420213305.GK26746@pb15.lixom.net>
	 <20060420.172742.132879746.davem@davemloft.net>
	 <44482EB5.9030605@hp.com>
	 <20060420.181302.98895633.davem@davemloft.net>
	 <4449127A.8050404@hp.com>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, olof@lixom.net,
	andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pproxy.gmail.com ([64.233.166.181]:29584 "EHLO pproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751760AbWD0Xt2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 19:49:28 -0400
Received: by pproxy.gmail.com with SMTP id i49so2237011pye
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 16:49:28 -0700 (PDT)
To: "Rick Jones" <rick.jones2@hp.com>
In-Reply-To: <4449127A.8050404@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Netperf2 TOT now accesses the buffer that was just recv()'d rather than
> the one that is about to be recv()'d.

We've posted netperf2 results with I/OAT enabled/disabled and the data
access option on/off at
http://kernel.org/pub/linux/kernel/people/grover/ioat/netperf-icb-1.5-postscaling-both.pdf

This link has also been added to the I/OAT page on the LinuxNet wiki.

- Chris
