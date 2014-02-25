From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: netfilter: Use ether_addr_copy
Date: Mon, 24 Feb 2014 19:17:01 -0500 (EST)
Message-ID: <20140224.191701.1833024589083119809.davem@davemloft.net>
References: <06d3e7e463c2bbfa8b5264e67daace1181ada090.1393142669.git.joe@perches.com>
	<8ffb523682d29d344873ad09b9c27faddcb90b5f.1393142669.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bart.de.schuymer@pandora.be, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaBYARD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:17:03 -0500
In-Reply-To: <8ffb523682d29d344873ad09b9c27faddcb90b5f.1393142669.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 23 Feb 2014 00:05:26 -0800

> Convert the uses of memcpy to ether_addr_copy because
> for some architectures it is smaller and faster.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Applied.
