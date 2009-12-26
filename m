From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 26 Dec 2009 10:05:14 -0500
Message-ID: <1261839914.3540.0.camel@bigi>
References: <1260731716.6167.27.camel@bigi>
	 <20091213.191024.193699730.davem@davemloft.net>
	 <1260785985.6167.29.camel@bigi>
	 <20091225.173042.189687657.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, hidden@balabit.hu, kaber@trash.net, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:60785 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbZLZPFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 10:05:25 -0500
Received: by qyk30 with SMTP id 30so4313435qyk.33
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2009 07:05:24 -0800 (PST)
In-Reply-To: <20091225.173042.189687657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-25 at 17:30 -0800, David Miller wrote:

> I hope this puts the tproxy regression to rest :-)

It should. The only open question is whether this is considered
a "bug fix" and needs to be propagated to -stable.

cheers,
jamal

