From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Wed, 8 Jan 2014 08:14:51 +0100
Message-ID: <20140108071451.GC9007@order.stressinduktion.org>
References: <20140106084827.GA5766@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	davem@davemloft.net, johnwheffner@gmail.com,
	steffen.klassert@secunet.com, fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47376 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026AbaAHHOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:14:52 -0500
Content-Disposition: inline
In-Reply-To: <20140106084827.GA5766@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 09:48:27AM +0100, Hannes Frederic Sowa wrote:
> v3)
> * forward_use_pmtu default enabled again

Okay, I fucked it up. So sorry...
