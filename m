From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [PATCH 0/4] spidernet: support for Celleb
Date: Wed, 14 Feb 2007 16:51:07 +0900 (JST)
Message-ID: <200702140751.l1E7p73x027147@toshiba.co.jp>
References: <20070212234959.GF923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, jim@jklewis.com
To: linas@austin.ibm.com, jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:34130 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbXBNHwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 02:52:07 -0500
In-Reply-To: <20070212234959.GF923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas-san, Jens-san,

> Tested this series of patches together with Jen's "version 3" patch,
> it worked for me. Code looks reasonable.  Thus

We tried Jens-san's v3 patch on Celleb, and it works for us.

We also need Linas-san's patch set which includes bug-fix and makes
the code compilable etc. But our previous patch set conflicts with
Linas-san's patch set.

So we will post a revised patch set for spider_net, which is based on
Jens-san's phy patch and Linas-san's spider_net patch.  The revised
patch set will differ from our previous patch set only by editorial
changes, so we think it will be ready to go in.


Best regards,
Kou Ishizaki
