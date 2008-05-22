From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/: remove CVS keywords
Date: Thu, 22 May 2008 06:09:36 -0400
Message-ID: <48354660.7060500@pobox.com>
References: <20080519220619.GL17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39628 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402AbYEVKJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:09:38 -0400
In-Reply-To: <20080519220619.GL17716@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch removes some CVS keywords that weren't updated for a long 
> time.
> 
> I haven't touched drivers that looked as if they might still be used.
> 
> In three drivers I've also removed printk's printing them since they 
> were part of several printk's in a row and it doesn't make sense to 
> print ancient version information to the user.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I'm fine with removing CVS keywords, but I do not agree with removing 
net driver version numbers that have been in the drivers for a while.

	Jeff



