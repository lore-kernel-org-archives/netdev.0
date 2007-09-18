From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 18:51:57 -0700 (PDT)
Message-ID: <20070917.185157.26533038.davem@davemloft.net>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753224AbXIRBwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 21:52:02 -0400
In-Reply-To: <20070917165318.36a1f1a7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 17 Sep 2007 16:53:18 -0700

> The Tehuti driver you should probably pull from the above git tree.

Ok I added in the Tehuti driver to net-2.6.24 and made sure the
napi_struct conversion was good too.

That only leaves the wireless bits :-)
