From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: don't expire permanent entries
Date: Wed, 31 Oct 2012 13:42:56 -0400 (EDT)
Message-ID: <20121031.134256.1408855723224918392.davem@davemloft.net>
References: <20121026092434.4d735316@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.southworth@vyatta.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758866Ab2JaRnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:43:02 -0400
In-Reply-To: <20121026092434.4d735316@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 26 Oct 2012 09:24:34 -0700

> VXLAN confused flag versus bitmap on state.
> Based on part of a earlier patch by David Stevens.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
