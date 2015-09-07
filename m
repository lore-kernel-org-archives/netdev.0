From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6171: add hardware 802.1Q
 support
Date: Sun, 06 Sep 2015 19:51:05 -0700 (PDT)
Message-ID: <20150906.195105.1398878220974561564.davem@davemloft.net>
References: <1441380144-26205-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbbIGCvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 22:51:07 -0400
In-Reply-To: <1441380144-26205-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  4 Sep 2015 11:22:24 -0400

> The Marvell 88E6171 switch is in the 88E6351 family, which supports
> 802.1Q, thus add support from the generic mv88e6xxx functions.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
