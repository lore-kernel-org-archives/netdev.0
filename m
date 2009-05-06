From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 06 May 2009 13:40:03 -0700 (PDT)
Message-ID: <20090506.134003.261424694.davem@davemloft.net>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-3-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jrigby@freescale.com, kosmo@semihalf.com,
	netdev@vger.kernel.org, grant.likely@secretlab.ca,
	jcrigby@gmail.com
To: wd@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43803
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761014AbZEFUkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:40:08 -0400
In-Reply-To: <1241640919-4650-3-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Would you be offended if I tell you that this is a horrible patch
submission?

Your introductory email indicates 16 patches, yet the series indicates
there were 12, and that intro email is only posted to the linuxppc-dev
list for people to read.  Nobody on netdev nor other interested
parties that get CC:'d along the line are able to read what this patch
series is about.

Since only some patches are CC:'d to netdev I have no idea if I should
apply these or they are dependent on some other patches in the series
that you didn't send here to netdev.

What a mess... how can any maintainer figure out what patch is what,
and what tree you expect these patches to even get applied to?

I'm definitely sending all of the copies I have received to /dev/null,
you need to submit this work properly.

