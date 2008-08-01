From: David Miller <davem@davemloft.net>
Subject: Re: _xmit_ETHER lockdep warning. (-git8)
Date: Fri, 01 Aug 2008 16:18:28 -0700 (PDT)
Message-ID: <20080801.161828.52517255.davem@davemloft.net>
References: <20080801192947.GA26210@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759036AbYHAXS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 19:18:29 -0400
In-Reply-To: <20080801192947.GA26210@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Fri, 1 Aug 2008 15:29:47 -0400

> A week or so old, but possibly still valid..
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=456521

Current Linus should have a fix for this.  Let me know if it
persists.
