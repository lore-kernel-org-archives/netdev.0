From: David Miller <davem@davemloft.net>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 15:43:16 -0700 (PDT)
Message-ID: <20070914.154316.59469764.davem@davemloft.net>
References: <46EB071B.9070308@candelatech.com>
	<20070914.152912.74747426.davem@davemloft.net>
	<46EB0D39.4030609@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58974
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753481AbXINWnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 18:43:17 -0400
In-Reply-To: <46EB0D39.4030609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 14 Sep 2007 15:37:45 -0700

> I will try the patch, but it will probably not be until Monday.
> The existing code actually can be made to work by passing in
> a 4+ byte string and setting the first byte to zero, and as
> far as I can see, that remains the same with the new patch.

You said the route wasn't cleared correctly in your test, and that's
one part I'm concerned about making sure is fixed.

To be honest I'm slightly angry at you.  I can travel for 24 hours
non-stop on trains and planes and still be mostly responsive to people
and apply patches.  But I simply ask you to test a simple patch for a
test case you said you already have and you can't do it until
Monday?!?!?

This is why I typically low priority all reports from you, sorry for
not doing so this time too. :-/

