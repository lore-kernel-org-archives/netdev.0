From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] network devices generating uevents?
Date: Fri, 21 Nov 2008 17:24:33 -0800 (PST)
Message-ID: <20081121.172433.65626835.davem@davemloft.net>
References: <20081121134659.5b305b5c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752977AbYKVBYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:24:34 -0500
In-Reply-To: <20081121134659.5b305b5c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Nov 2008 13:46:59 -0800

> Perhaps the following would make it easier for applications to
> track network device events without having to use netlink.
> Compile tested only so far. The implementation is almost trivial...

I'm fine with this, what do others think?
