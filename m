From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Mon, 03 Nov 2008 17:12:56 -0800 (PST)
Message-ID: <20081103.171256.03711206.davem@davemloft.net>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081102.002736.193701976.davem@davemloft.net>
	<649aecc70811031419o78e9046eu52adf78eef8da7d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rick.jones2@hp.com, rhee@eos.ncsu.edu,
	netdev@vger.kernel.org
To: sangtae.ha@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52773
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbYKDBNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:13:21 -0500
In-Reply-To: <649aecc70811031419o78e9046eu52adf78eef8da7d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sangtae Ha" <sangtae.ha@gmail.com>
Date: Mon, 3 Nov 2008 17:19:52 -0500

> We had rather extensive testings with one MacOSX receiver of the
> latest Leopard release.
> As we had one macbook pro available in the lab, all the testing
> results are with the one receiver.
> Based on the tested results, MacOSX also doesn't break the algorithm.
> 
> Please see the results at the following:
> 
> http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing#Testing_with_MacOSX

Just like Stephen, I'd like to thank you for doing this
testing.
