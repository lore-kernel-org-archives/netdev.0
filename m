From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9 net-next-2.6] [TIPC]: Fix recursive spinlock
 invocation in print buffer code
Date: Mon, 05 May 2008 01:21:22 -0700 (PDT)
Message-ID: <20080505.012122.160526045.davem@davemloft.net>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
	<1209412126-2109-4-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752821AbYEEIVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 04:21:22 -0400
In-Reply-To: <1209412126-2109-4-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 28 Apr 2008 15:48:40 -0400

> This patch fixes two routines that allow the global print buffer
> spinlock to be taken recursively.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
