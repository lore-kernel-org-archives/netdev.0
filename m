From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] 8139*: convert printk() to pr_<foo>()
Date: Tue, 26 May 2009 20:35:58 -0700 (PDT)
Message-ID: <20090526.203558.67542883.davem@davemloft.net>
References: <1243377327-8313-1-git-send-email-a.beregalov@gmail.com>
	<1243377327-8313-2-git-send-email-a.beregalov@gmail.com>
	<1243377327-8313-3-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48852
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754875AbZE0Df6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:35:58 -0400
In-Reply-To: <1243377327-8313-3-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Wed, 27 May 2009 02:35:27 +0400

> Also convert DPRINTK to pr_debug and dev_printk to dev_<foo>.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Applied.
