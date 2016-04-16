From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/5] Add support for offloads with IPv6 GRE
 tunnels
Date: Sat, 16 Apr 2016 19:12:04 -0400 (EDT)
Message-ID: <20160416.191204.36798231616713108.davem@davemloft.net>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbcDPXMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 19:12:07 -0400
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Thu, 14 Apr 2016 15:33:30 -0400

> This patch series enables the use of segmentation and checksum
> offloads with IPv6 based GRE tunnels.

Series applied, nice work Alex.
