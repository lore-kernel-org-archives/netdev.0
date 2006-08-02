From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DECnet Fix for DECnet routing bug
Date: Wed, 02 Aug 2006 14:14:56 -0700 (PDT)
Message-ID: <20060802.141456.18710574.davem@davemloft.net>
References: <44D0B46C.2040500@tykepenguin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27040
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932132AbWHBVOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:14:46 -0400
To: patrick@tykepenguin.com
In-Reply-To: <44D0B46C.2040500@tykepenguin.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick Caulfield <patrick@tykepenguin.com>
Date: Wed, 02 Aug 2006 15:19:24 +0100

> This patch fixes a bug in the DECnet routing code where we were selecting
> a loopback device in preference to an outward facing device even when
> the destination was known non-local. This patch should fix the problem.
> 
> Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>
> Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

Applied, thanks Patrick.
