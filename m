From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CAIF: write check
Date: Wed, 07 Apr 2010 16:49:40 -0700 (PDT)
Message-ID: <20100407.164940.235874045.davem@davemloft.net>
References: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
	<81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
	<20100407141703.7c0a4a65@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756060Ab0DGXth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:49:37 -0400
In-Reply-To: <20100407141703.7c0a4a65@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 7 Apr 2010 14:17:03 +0100

> caif: check write operations
> 
> From: Alan Cox <alan@linux.intel.com>
> 
> write is optional for a tty device. Check that we have a write op rather
> than calling NULL.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied, thanks Alan.
