From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/stmmac: seq_file fix memory leak
Date: Mon, 21 May 2012 03:38:23 -0400 (EDT)
Message-ID: <20120521.033823.1342827628402855282.davem@davemloft.net>
References: <20120520235530.GA22698@dztty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: tixxdz@opendz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab2EUHic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 03:38:32 -0400
In-Reply-To: <20120520235530.GA22698@dztty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Djalal Harouni <tixxdz@opendz.org>
Date: Mon, 21 May 2012 00:55:30 +0100

> Use single_release() instead of seq_release() to free memory allocated
> by single_open().
> 
> Signed-off-by: Djalal Harouni <tixxdz@opendz.org>

Applied, thanks.
