From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 17:15:24 -0700 (PDT)
Message-ID: <20070917.171524.43502946.davem@davemloft.net>
References: <20070917144037.100b3fc1.akpm@linux-foundation.org>
	<20070917.163929.107941522.davem@davemloft.net>
	<20070917165318.36a1f1a7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jgarzik@pobox.com,
	andy@greyhouse.net, romieu@fr.zoreil.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756079AbXIRAPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 20:15:34 -0400
In-Reply-To: <20070917165318.36a1f1a7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 17 Sep 2007 16:53:18 -0700

> The Tehuti driver you should probably pull from the above git tree.
> 
> Andy sent me a fix-it-for-net-2.6.24 patch which I'll send.  It applies
> on top of the git tree.
> 
> ipg-add-ip1000a-driver-to-kernel-tree.patch got broken by git-2.6.24 and I
> just disabled it in Kconfig.  I'll send it anyway but someone will need to
> repair it.  For some reason this driver doesn't have a changelog.

I integrated and fixed up the IPG IP1000A driver, I'll work on
the Tehuti merge after dinner.

Thanks Andrew.

