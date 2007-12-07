From: David Miller <davem@davemloft.net>
Subject: Re: [SCTP] Bug fixes to the migrate/accept code path.
Date: Thu, 06 Dec 2007 22:51:09 -0800 (PST)
Message-ID: <20071206.225109.48331808.davem@davemloft.net>
References: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751097AbXLGGvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 01:51:10 -0500
In-Reply-To: <1196963304-32494-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu,  6 Dec 2007 12:48:22 -0500

> The following two patches fix some bugs in the SCTP accept code path.
> The first one fixes a slab corruption bug that we found during stress
> testing.  The second one is just a clean-up and the right way to do things.

Both patches applied to net-2.6, thanks Vlad!
