From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: set netdev->vlan_features
Date: Mon, 18 Apr 2016 14:53:30 -0400 (EDT)
Message-ID: <20160418.145330.146676524687501437.davem@davemloft.net>
References: <1460747443-14993-1-git-send-email-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, mkubecek@suse.com,
	_govind@gmx.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcDRSxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 14:53:32 -0400
In-Reply-To: <1460747443-14993-1-git-send-email-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Sat, 16 Apr 2016 00:40:43 +0530

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> 
> Driver sets vlan_feature to netdev->features as hardware supports all of
> them on vlan interface.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
