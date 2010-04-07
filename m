From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] socket: remove duplicate declaration of struct timespec
Date: Tue, 06 Apr 2010 19:51:24 -0700 (PDT)
Message-ID: <20100406.195124.178688602.davem@davemloft.net>
References: <1270568392-22030-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752199Ab0DGCvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 22:51:20 -0400
In-Reply-To: <1270568392-22030-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue,  6 Apr 2010 17:39:52 +0200

> struct timespec ts was alreay defined. Reuse the previously
> defined one and reduce the memory footprint on the stack by
> 16 bytes.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied, thanks.
