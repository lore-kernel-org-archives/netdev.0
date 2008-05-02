From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] dccp: ccid2.c, ccid3.c use clamp(), clamp_t()
Date: Fri, 02 May 2008 16:44:15 -0700 (PDT)
Message-ID: <20080502.164415.255520956.davem@davemloft.net>
References: <200805022039.m42KdTeq013605@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com,
	acme@ghostprotocols.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762872AbYEBXoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:44:16 -0400
In-Reply-To: <200805022039.m42KdTeq013605@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 02 May 2008 13:39:28 -0700

> From: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Makes the intention of the nested min/max clear.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
