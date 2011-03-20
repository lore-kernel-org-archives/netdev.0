From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ROSE: prevent heap corruption with bad facilities
Date: Sat, 19 Mar 2011 23:07:54 -0700 (PDT)
Message-ID: <20110319.230754.226782746.davem@davemloft.net>
References: <1300577313.12507.17.camel@dan>
	<1300601004.1869.1.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab1CTGHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 02:07:16 -0400
In-Reply-To: <1300601004.1869.1.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Sun, 20 Mar 2011 02:03:24 -0400

> Please disregard this patch, my brain wasn't working properly when I
> wrote it.  There are problems in these areas, but this fix is incomplete
> (and the description for the first issue is practically nonsensical).
> I'll resend a new version shortly.

Ok.
