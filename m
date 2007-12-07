From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/20] net/core/dev.c: use LIST_HEAD instead of
 LIST_HEAD_INIT
Date: Fri, 07 Dec 2007 00:49:25 -0800 (PST)
Message-ID: <20071207.004925.95633140.davem@davemloft.net>
References: <1196956886-5681-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58617
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751923AbXLGIt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:49:26 -0500
In-Reply-To: <1196956886-5681-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Cheng <crquan@gmail.com>
Date: Fri,  7 Dec 2007 00:01:26 +0800

> single list_head variable initialized with LIST_HEAD_INIT could almost
> always can be replaced with LIST_HEAD declaration, this shrinks the code
> and looks better.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Applied.
