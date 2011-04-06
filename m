From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] capi: Perform scheduled capifs removal
Date: Wed, 06 Apr 2011 14:45:50 -0700 (PDT)
Message-ID: <20110406.144550.212398094.davem@davemloft.net>
References: <1302080739-4029-1-git-send-email-amwang@redhat.com>
	<4D9CD3FD.3000604@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, isdn@linux-pingi.de
To: jan.kiszka@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54067
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932245Ab1DFVq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:46:27 -0400
In-Reply-To: <4D9CD3FD.3000604@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Kiszka <jan.kiszka@web.de>
Date: Wed, 06 Apr 2011 22:58:37 +0200

> udev fully replaces this special file system that only contains CAPI
> NCCI TTY device nodes. User space (pppdcapiplugin) works without
> noticing the difference.
> 
> Signed-off-by: Jan Kiszka <jan.kiszka@web.de>

Applied, thanks Jan.
