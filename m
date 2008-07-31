From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 17:20:33 -0700 (PDT)
Message-ID: <20080730.172033.261797728.davem@davemloft.net>
References: <200807310004.m6V04gcw025147@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com,
	samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754260AbYGaAUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:20:34 -0400
In-Reply-To: <200807310004.m6V04gcw025147@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 17:04:41 -0700

> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks for the respin Andrew.
