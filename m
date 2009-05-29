From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] netdev: bfin_mac: add Blackfin MII bus to platform
 bus to allow DSA access
Date: Fri, 29 May 2009 02:09:16 -0700 (PDT)
Message-ID: <20090529.020916.252005963.davem@davemloft.net>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	<1243404615-25879-5-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	graf.yang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756379AbZE2JJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 05:09:16 -0400
In-Reply-To: <1243404615-25879-5-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 27 May 2009 02:10:14 -0400

> From: Graf Yang <graf.yang@analog.com>
> 
> When we register the MII bus to the platfrom bus, the Distributed Switch
> Architecture can hook in transparently.
> 
> Signed-off-by: Graf Yang <graf.yang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied to net-next-2.6
