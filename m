From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] skge: fiber support
Date: Wed, 27 Sep 2006 13:59:02 -0400
Message-ID: <20060927175900.GC6030@mathom.us>
References: <20060815131852.GP2900@mathom.us>
 <20060921153939.739947ab@dxpl.pdx.osdl.net> <20060926154459.GA6030@mathom.us>
 <20060927172644.GA14294@mathom.us> <20060927103415.21bdccc9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:8354 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S1030509AbWI0R7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 13:59:13 -0400
Received: from osgiliath.mathom.us ([72.66.19.85])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J69008J9JAJL4R4@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 27 Sep 2006 12:59:07 -0500 (CDT)
In-reply-to: <20060927103415.21bdccc9@freekitty>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 10:34:15AM -0700, Stephen Hemminger wrote:
>That's surprising, memory leak? dropped packets?

I'm open to suggestions on debugging it. It seems fairly repeatable 
about half an hour after startup.

Mike Stone
