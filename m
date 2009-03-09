From: David Miller <davem@davemloft.net>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 09 Mar 2009 16:52:05 -0700 (PDT)
Message-ID: <20090309.165205.11054081.davem@davemloft.net>
References: <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	<20090309195906.M50328@bts.sk>
	<1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: md@bts.sk, netdev@vger.kernel.org
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752395AbZCIXwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 19:52:19 -0400
In-Reply-To: <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Heffner <johnwheffner@gmail.com>
Date: Mon, 9 Mar 2009 13:23:15 -0700

> A drop-tail queue size of 1000 packets on a local interface is
> questionable, and I think this is the real source of your problem.

Are you suggested we decrease it? :-)
