From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] netdev: smsc911x: allow building on any system
Date: Tue, 09 Jun 2009 01:37:18 -0700 (PDT)
Message-ID: <20090609.013718.135786197.davem@davemloft.net>
References: <OFFCE515A9.69B05047-ON802575D0.002BA8D0-802575D0.002C553B@smsc.com>
	<1244535742-9804-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756728AbZFIIhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:37:16 -0400
In-Reply-To: <1244535742-9804-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Tue,  9 Jun 2009 04:22:22 -0400

> The smsc911x driver should build fine on any system as it contains no arch
> specific code (all platform resources), and any platform that has
> appropriate resources should run fine (as it does on Blackfin systems).
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Mike I already applied your previous patch.

You'll need to send me a patch relative to that.
