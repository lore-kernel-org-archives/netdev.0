From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] skge: fiber support
Date: Wed, 27 Sep 2006 13:26:46 -0400
Message-ID: <20060927172644.GA14294@mathom.us>
References: <20060815131852.GP2900@mathom.us>
 <20060921153939.739947ab@dxpl.pdx.osdl.net> <20060926154459.GA6030@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:33450 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S1030470AbWI0R1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 13:27:40 -0400
Received: from osgiliath.mathom.us ([72.66.19.85])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J690086CHSQL7T4@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 27 Sep 2006 12:26:51 -0500 (CDT)
In-reply-to: <20060926154459.GA6030@mathom.us>
To: Stephen Hemminger <shemminger@osdl.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm. Yesterday I did some nfs testing (simple dd of a big file) with the 
skge driver and got about 700+Mbps. I ran the same test today and got 
160Mbps. I rebooted the client and got 700+Mbps again. About half an 
hour later, down to 160Mbps again. Server & client were both idle, and 
the server didn't change (no reboots). For reference, the sk98lin gets 
around 600Mbps, consistently.

Mike Stone
