From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Wed, 07 Dec 2011 23:56:02 -0500 (EST)
Message-ID: <20111207.235602.1465915988125994516.davem@davemloft.net>
References: <CAM7b5hzt8D6hn3=XEcm9E3_BwJxj-YABpkufCpuhjiPLDxCsMQ@mail.gmail.com>
	<20111206173220.GA28763@kroah.com>
	<CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, jwboyer@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: artisdom@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab1LHE4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 23:56:12 -0500
In-Reply-To: <CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ted Feng <artisdom@gmail.com>
Date: Thu, 8 Dec 2011 11:35:15 +0800

> @@ -285,6 +285,8 @@ static struct ip_tunnel *
> ipip_tunnel_locate(struct net *net,

Your patches are corrupted by your email client and unusable.
