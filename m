From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] veth: Update features to include all
 tunnel GSO types
Date: Thu, 21 Apr 2016 14:15:16 -0400 (EDT)
Message-ID: <20160421.141516.708458160284189592.davem@davemloft.net>
References: <20160419180219.11003.78651.stgit@ahduyck-xeon-server>
	<20160419180226.11003.43326.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcDUSPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:15:18 -0400
In-Reply-To: <20160419180226.11003.43326.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 19 Apr 2016 14:02:26 -0400

> This patch adds support for the checksum enabled versions of UDP and GRE
> tunnels.  With this change we should be able to send and receive GSO frames
> of these types over the veth pair without needing to segment the packets.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied.
