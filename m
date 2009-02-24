From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gre: used time_before for comparing jiffies
Date: Mon, 23 Feb 2009 23:41:19 -0800 (PST)
Message-ID: <20090223.234119.202943878.davem@davemloft.net>
References: <499E2C54.9000409@cn.fujitsu.com>
	<20090224071352.GA20925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbZBXHli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 02:41:38 -0500
In-Reply-To: <20090224071352.GA20925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Feb 2009 15:13:52 +0800

> Wei Yongjun <yjwei@cn.fujitsu.com> wrote:
> > The functions time_before is more robust for comparing
> > jiffies against other values.
> > 
> > Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Please resubmit these patches so that they can be reviewed again.

Indeed, I think my original objections have been cleared up
after some research.
