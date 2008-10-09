From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: fix usb usage on big endian platforms
Date: Thu, 09 Oct 2008 14:35:19 -0700 (PDT)
Message-ID: <20081009.143519.174053977.davem@davemloft.net>
References: <1223556794-29405-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com, jeff@garzik.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47448
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756720AbYJIVfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:35:43 -0400
In-Reply-To: <1223556794-29405-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu,  9 Oct 2008 13:53:14 +0100

> Fix warnings caught by David Miller on ppc64
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

I fixed the commit message to say "sparc64" instead of
"ppc64" for accuracy, and applied your patch.

Thanks.
