From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next v9] Open vSwitch
Date: Thu, 24 Jul 2014 23:18:38 -0700 (PDT)
Message-ID: <20140724.231838.1810059908400379250.davem@davemloft.net>
References: <1406237956-1601-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaGYGSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:18:40 -0400
In-Reply-To: <1406237956-1601-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 24 Jul 2014 14:39:16 -0700

> Following patches adds three features to OVS
> 1. Add fairness to upcall processing.
> 2. Hash action.
> 3. Enable Tunnel GSO features.
> Rest of patches are bug fixes related to patches from same series.
> 
> v2 series changes first patch according to comment from Dave Miller.
> v3 series changes first patch according to comment from Nikolay Aleksandrov.
> v4 series update recirc patch commit msg.
> v5 series resolve conflict with net-next, updated recic action patch.
> v6 series sends all patches.
> v7 series drop recirc patches.
> v8 series checkpatch fix 
> v9 series drop HASH action patch. update sample action commit msg.

Pulled, thanks Pravin.
