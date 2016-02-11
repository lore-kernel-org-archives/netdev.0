From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/8] Local Checksum Offload
Date: Thu, 11 Feb 2016 07:29:03 -0500 (EST)
Message-ID: <20160211.072903.1590178314107608298.davem@davemloft.net>
References: <56B50886.1050201@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	tom@herbertland.com, alexander.duyck@gmail.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcBKM3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 07:29:07 -0500
In-Reply-To: <56B50886.1050201@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 5 Feb 2016 20:39:34 +0000

> Tested with VxLAN, GRE and FOU-IPIP tunnels.  Not tested with GENEVE,
>  because iproute2 doesn't support enabling checksums on GENEVE tunnels.
> Also tested VxLAN with IPv6 (as both inner and outer protocol).

This gets rejects when I try to apply it, please respin.

Thanks!
