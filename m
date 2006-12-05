From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for
 mobility header.
Date: Wed, 06 Dec 2006 00:28:11 +0900 (JST)
Message-ID: <20061206.002811.95754004.yoshfuji@linux-ipv6.org>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org>
	<20061205.200242.01826773.yoshfuji@linux-ipv6.org>
	<45758A6E.9010209@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nakam@linux-ipv6.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39268 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968297AbWLEP16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 10:27:58 -0500
To: brian.haley@hp.com
In-Reply-To: <45758A6E.9010209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <45758A6E.9010209@hp.com> (at Tue, 05 Dec 2006 10:04:14 -0500), Brian Haley <brian.haley@hp.com> says:

> YOSHIFUJI Hideaki wrote:
> >> Add checksum default defines for mobility header(MH).
> >> As the result kernel's behavior is to handle MH checksum
> >> as default.
> > 
> > I'd like to hold this on.  I need to check RFC.
> 
> That looks correct according to 3775.

I'm thinking about difference RFC.

--yoshfuji
