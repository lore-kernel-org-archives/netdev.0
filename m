From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic - Fix scheduling while atomic bug
Date: Thu, 27 Sep 2012 18:21:33 -0400 (EDT)
Message-ID: <20120927.182133.1396850191643578552.davem@davemloft.net>
References: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	jitendra.kalsaria@qlogic.com, john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287Ab2I0WVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:21:35 -0400
In-Reply-To: <20120925175212.GA1324@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is it really the case that not one Qlogic person feels like ACK'ing
this patch that fixes an obvious bug in their driver for 2 full days?

For real?
