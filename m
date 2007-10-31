From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: suppress a warning for 64k pages.
Date: Tue, 30 Oct 2007 23:58:04 -0700 (PDT)
Message-ID: <20071030.235804.99443518.davem@davemloft.net>
References: <20071031153422.44f864e8.sfr@canb.auug.org.au>
	<20071030.214219.256397507.davem@davemloft.net>
	<20071031162452.fcea4431.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752709AbXJaG6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 02:58:05 -0400
In-Reply-To: <20071031162452.fcea4431.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 Oct 2007 16:24:52 +1100

> On PowerPC allmodconfig build we get this:
> 
> net/key/af_key.c:400: warning: comparison is always false due to limited range of data type
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks Stephen.
