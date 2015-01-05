From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Geneve Cleanups
Date: Sun, 04 Jan 2015 22:22:12 -0500 (EST)
Message-ID: <20150104.222212.144188607058593716.davem@davemloft.net>
References: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbbAEDWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 22:22:15 -0500
In-Reply-To: <1420251965-44794-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri,  2 Jan 2015 18:26:01 -0800

> Much of the basis for the Geneve code comes from VXLAN. However,
> Geneve is quite a bit simpler than VXLAN and so this cleans up a
> lot of the infrastruction - particularly around locking - where the
> extra complexity is not necessary.

I like it, series applied, thanks Jesse.
