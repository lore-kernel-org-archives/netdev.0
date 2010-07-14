From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/11] Removing dead SH_HICOSH4
Date: Wed, 14 Jul 2010 13:40:46 -0700 (PDT)
Message-ID: <20100714.134046.104048236.davem@davemloft.net>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<33b39de0da0638cd6a878e222e298f39ab82a5b2.1279110895.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, shemminger@vyatta.com,
	dongdong.deng@windriver.com, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: siccegge@cs.fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49290
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757934Ab0GNUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:40:30 -0400
In-Reply-To: <33b39de0da0638cd6a878e222e298f39ab82a5b2.1279110895.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:41:14 +0200

> SH_HICOSH4 doesn't exist in Kconfig, therefore removing all references
> for it from the source code.
> 
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

Applied.
