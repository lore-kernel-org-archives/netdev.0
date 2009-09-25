From: David Miller <davem@davemloft.net>
Subject: Re: [PULL] virtio_net updates
Date: Fri, 25 Sep 2009 11:09:26 -0700 (PDT)
Message-ID: <20090925.110926.58080108.davem@davemloft.net>
References: <200909241005.59416.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	markmc@redhat.com, dineshs@us.ibm.com, amit.shah@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36370
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbZIYSJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 14:09:07 -0400
In-Reply-To: <200909241005.59416.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 24 Sep 2009 10:05:58 +0930

>    Now Linus has the prereq add_buf changes, these can all feed via
> you.  Note that the driver is changed to return TX_BUSY first which
> is simplest, then complicated again to avoid it.

Pulled, thanks a lot!
