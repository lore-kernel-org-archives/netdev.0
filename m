From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: consolidate output route calculation
Date: Thu, 03 Dec 2015 15:25:07 -0500 (EST)
Message-ID: <20151203.152507.2076390764541090334.davem@davemloft.net>
References: <65e2af7ff108b1c7b477c3df91382bb9e4662edf.1449141813.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, pshelar@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbLCUZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:25:08 -0500
In-Reply-To: <65e2af7ff108b1c7b477c3df91382bb9e4662edf.1449141813.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu,  3 Dec 2015 12:23:57 +0100

> The code for output route lookup is duplicated for ndo_start_xmit and
> ndo_fill_metadata_dst. Move it to a common function.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied to net-next, thanks.
