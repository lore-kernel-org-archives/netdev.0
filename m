From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Tue, 10 Feb 2015 10:57:13 +0100
Message-ID: <20150210095712.GE13046@secunet.com>
References: <5487DD65.60800@gtsys.com.hk>
 <549AC2B4.8070203@gtsys.com.hk>
 <1420560073.32369.60.camel@redhat.com>
 <20150126083512.GI13046@secunet.com>
 <54C71AFB.40300@gtsys.com.hk>
 <20150127115814.GL13046@secunet.com>
 <54D46F50.7020104@gtsys.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hannes Frederic Sowa <hannes@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47797 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432AbbBJJ5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Feb 2015 04:57:23 -0500
Content-Disposition: inline
In-Reply-To: <54D46F50.7020104@gtsys.com.hk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2015 at 03:37:52PM +0800, Chris Ruehl wrote:
> Hi Steffen,
> 
> server is up for 6 days no problems any more.
> Please apply the patch!
> 
> Thank you very much
> Chris
> 
> Tested-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>

Now applied to the ipsec tree. Thanks a lot for testing Chris!
