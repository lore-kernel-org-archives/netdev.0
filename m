From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] bnx2: Prevent ethtool -s from crashing
 when device is down.
Date: Mon, 14 Jul 2008 22:37:29 -0700 (PDT)
Message-ID: <20080714.223729.125902266.davem@davemloft.net>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753572AbYGOFh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:37:28 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 10 Jul 2008 18:29:10 -0700

> The device may be in D3-hot state and may crash if we try to
> configure the speed settings by accessing the registers.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
