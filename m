From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: push BKL down into the driver
Date: Sun, 25 May 2008 23:41:07 -0700 (PDT)
Message-ID: <20080525.234107.30123206.davem@davemloft.net>
References: <20080522215711.46fa07ac@core>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.com
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752551AbYEZGlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 02:41:12 -0400
In-Reply-To: <20080522215711.46fa07ac@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 22 May 2008 21:57:11 +0100

> I've pushed it down as far as I dare at this point. Someone familiar with
> the internal PPP semantics can probably push it further. Another step to
> eliminating the old BKL ioctl usage.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>

Applied.
