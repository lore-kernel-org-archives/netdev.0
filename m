From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] cxgb4: notify upper drivers if the device is
 already up when they load
Date: Tue, 18 May 2010 15:17:08 -0700 (PDT)
Message-ID: <20100518.151708.199018243.davem@davemloft.net>
References: <1274213233-26309-1-git-send-email-dm@chelsio.com>
	<1274213233-26309-2-git-send-email-dm@chelsio.com>
	<1274213233-26309-3-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755754Ab0ERWQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:16:59 -0400
In-Reply-To: <1274213233-26309-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 18 May 2010 13:07:13 -0700

> Upper layer drivers aren't notified that a device is ready if their modules
> load after the device becomes ready.  Add the missing notification.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
