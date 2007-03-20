From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] x25_forward_call(): fix NULL dereferences
Date: Mon, 19 Mar 2007 17:03:47 -0700 (PDT)
Message-ID: <20070319.170347.126762285.davem@davemloft.net>
References: <20070319092403.GK752@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51415
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030773AbXCTADr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 20:03:47 -0400
In-Reply-To: <20070319092403.GK752@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 19 Mar 2007 10:24:03 +0100

> This patch fixes two NULL dereferences spotted by the Coverity checker.
> 
> For a better understanding, the "diff -uwp" output (that ignores the 
> indentation changes) is:

I'll apply this, thanks Adrian.
