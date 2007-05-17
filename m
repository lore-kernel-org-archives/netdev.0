From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP YeAH selects TCP Vegas with Kconfig
Date: Thu, 17 May 2007 13:42:46 -0700 (PDT)
Message-ID: <20070517.134246.115638564.davem@davemloft.net>
References: <20070517185429.GA882@ifup.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: brandon@ifup.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757674AbXEQUmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 16:42:44 -0400
In-Reply-To: <20070517185429.GA882@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brandon Philips <brandon@ifup.org>
Date: Thu, 17 May 2007 11:54:29 -0700

> I tried building TCP YeAH into my kernel with TCP Vegas as a module and
> the build failed because TCP YeAH depends on Vegas.  This patch makes
> Kconfig aware of the YeAH dependency on Vegas.

I fixed this and posted the patch for it yesterday.
