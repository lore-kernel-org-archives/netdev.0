From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] via-velocity: Enable scatter/gather IO by
 default
Date: Tue, 16 Feb 2010 22:23:21 -0800 (PST)
Message-ID: <20100216.222321.112594777.davem@davemloft.net>
References: <20100211163955.1b1dbe2c@marrow.netinsight.se>
	<20100216.162015.77292959.davem@davemloft.net>
	<20100217071944.14183e50@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751158Ab0BQGXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:23:05 -0500
In-Reply-To: <20100217071944.14183e50@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Wed, 17 Feb 2010 07:19:44 +0100

> Well I reenabled it here:
> 
>   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=c79992fddee28bbd31b35ac297e1068d32930179
> 
> it was also cleaned up to remove all the #ifdefs around that code.

Ok, great.

I'll apply this patch to turn it on by default then.
