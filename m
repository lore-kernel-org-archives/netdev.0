From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4 - rev2] Add new timeval_to_sec function
Date: Tue, 21 Aug 2007 16:39:34 +0530
Message-ID: <46CAC7EE.8030009@linux.vnet.ibm.com>
References: <20070820134536.d260585a.varunc@linux.vnet.ibm.com> <20070820075325.43bd8f60@freepuppy.rosehill.hemminger.net> <46CA5E75.9050904@linux.vnet.ibm.com> <4f6ba3b0708210258k779ff97x87edbb4ace091d0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Bob Beers <bob.beers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51569 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbXHULJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 07:09:02 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LB9245004240
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 07:09:02 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LB92kV268180
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 05:09:02 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LB91Id003560
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2007 05:09:02 -0600
In-Reply-To: <4f6ba3b0708210258k779ff97x87edbb4ace091d0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bob Beers wrote:
> What if the name of the function was more descriptive of what the
>  function actually does?  Maybe timeval_ceil_sec()?
>   
Looks ok, it can be done if everyone is ok with it.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

