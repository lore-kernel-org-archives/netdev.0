From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next v5] Open vSwitch
Date: Sun, 20 Jul 2014 21:00:24 -0700 (PDT)
Message-ID: <20140720.210024.1201684667308639381.davem@davemloft.net>
References: <1405662895-2046-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaGUEAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 00:00:25 -0400
In-Reply-To: <1405662895-2046-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 17 Jul 2014 22:54:55 -0700

> Following patches adds three features to OVS
> 1. Add fairness to upcall processing.
> 2. Recirculation and Hash action.
> 3. Enable Tunnel GSO features.
> Rest of patches are bug fixes related to patches from same series.
> 
> v2 series changes first patch according to comment from Dave Miller.
> v3 series changes first patch according to comment from Nikolay Aleksandrov.
> v4 series chage recirc patch commit msg.
> v5 series resolve conflict with net-next, updated recic action patch.

Please do not just provide a pull request, post the entire patch
series.
