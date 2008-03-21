From: David Miller <davem@davemloft.net>
Subject: Re: possible lockdep crash
Date: Fri, 21 Mar 2008 04:04:08 -0700 (PDT)
Message-ID: <20080321.040408.153242166.davem@davemloft.net>
References: <20080321093052.M39677@visp.net.lb>
	<20080321.033530.249188954.davem@davemloft.net>
	<20080321105404.M46676@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754247AbYCULDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 07:03:51 -0400
In-Reply-To: <20080321105404.M46676@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Date: Fri, 21 Mar 2008 12:54:50 +0200

> Let me know if i can improve output to help debugging.
> If possible it must be minimal risk to hang, cause router is in very 
> difficult to reach area.

Can you disable lockdep and see if the problem persists?

It's killing your routing performance anyways, I have no
idea why you have it enabled.
