From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [drivers/net/cxgb3] removed several unneeded zero initilization
Date: Mon, 30 Jul 2007 16:04:19 -0400
Message-ID: <46AE4443.7040904@garzik.org>
References: <11847434891556-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bugs@chelsio.com, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, cr_quan@163.com
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55798 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968481AbXG3UEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 16:04:32 -0400
In-Reply-To: <11847434891556-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> Cc: linux-bugs@chelsio.com
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  drivers/net/cxgb3/cxgb3_main.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

applied


