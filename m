From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/5] ss: Get udp sockets info via sock-diag
Date: Fri, 26 Oct 2012 17:51:54 -0700
Message-ID: <20121026175154.69cf229a@nehalam.linuxnetplumber.net>
References: <50893BAF.7030500@parallels.com>
	<50893DAA.3010909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43006 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515Ab2J0Awn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:52:43 -0400
In-Reply-To: <50893DAA.3010909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Oct 2012 17:24:58 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Now everything is prepared for it, so the patch is straightforward.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 

1-4 standalone and do not require latest kernel; therefore applied

Please resubmit #5 during next merge window.
