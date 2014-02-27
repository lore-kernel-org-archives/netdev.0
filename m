From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/1] net: Add doc on how SKBs work
Date: Thu, 27 Feb 2014 16:06:05 -0500 (EST)
Message-ID: <20140227.160605.1514355233421544.davem@redhat.com>
References: <1393416659-10868-1-git-send-email-Neil.Jerram@metaswitch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil.Jerram@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410AbaB0VGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 16:06:17 -0500
In-Reply-To: <1393416659-10868-1-git-send-email-Neil.Jerram@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Jerram <Neil.Jerram@metaswitch.com>
Date: Wed, 26 Feb 2014 12:10:58 +0000

> I'm ramping up on Linux networking and found the material at
> http://vger.kernel.org/~davem/skb_data.html very useful.  Therefore
> here is a patch to copy that into a Documentation/networking file in
> the Linux tree.
> 
> Is this kind of thing welcome?  If it is, I'm aware that:
> 
> - some of the details are out of date
> 
> - more material would be useful on other pointers into the data area,
>   such as the MAC and network headers
> 
> and would propose to work on addressing those in subsequent changes.

Putting knowingly inaccurate documentation into the tree can be worse
than no documentation at all.   I wrote that nearly 10 years ago.

I'll try to go through it and bring it up to date.  But no promises on
a time frame in which I'll be able to do that.
