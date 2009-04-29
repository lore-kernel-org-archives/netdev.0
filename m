From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 3/3] netxen: fix firmware download
Date: Tue, 28 Apr 2009 23:01:03 -0700 (PDT)
Message-ID: <20090428.230103.78657054.davem@davemloft.net>
References: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
	<1240968551-13186-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752520AbZD2GBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 02:01:09 -0400
In-Reply-To: <1240968551-13186-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue, 28 Apr 2009 18:29:11 -0700

> o hold the firmware in memory across suspend, since filesystem
>   may not be up after resuming.
> o reset the chip after requesting firmware, to minimize downtime
>   for NC-SI.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
