From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/7] qla3xxx: bugfix: Add tx control block memset.
Date: Wed, 28 Mar 2007 02:19:24 -0400
Message-ID: <460A08EC.1080208@garzik.org>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org> <11749417831486-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42319 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201AbXC1GTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:25 -0400
In-Reply-To: <11749417831486-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> This was removed in a previous patch to increase performance, but
> caused a transmit error for the 4032 chip.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qla3xxx.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied 1-4 to #upstream-fixes


