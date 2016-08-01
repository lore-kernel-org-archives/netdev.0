From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: amd-xgbe: use correct format specifier
Date: Mon, 01 Aug 2016 13:44:04 -0700 (PDT)
Message-ID: <20160801.134404.1823135587450457756.davem@davemloft.net>
References: <1469952438-20493-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124AbcHAUuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:50:12 -0400
In-Reply-To: <1469952438-20493-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 10:07:18 +0200

> i has been defined as unsigned int.
> So use %u for output.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
