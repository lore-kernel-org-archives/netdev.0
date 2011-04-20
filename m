From: David Miller <davem@davemloft.net>
Subject: Re: Add missing socket check in can/bcm release.
Date: Tue, 19 Apr 2011 20:37:20 -0700 (PDT)
Message-ID: <20110419.203720.02289813.davem@davemloft.net>
References: <20110420033001.GA32635@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54372
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111Ab1DTDhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 23:37:55 -0400
In-Reply-To: <20110420033001.GA32635@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 19 Apr 2011 23:30:01 -0400

> We can get here with a NULL socket argument passed from userspace,
> so we need to handle it accordingly.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks Dave.
