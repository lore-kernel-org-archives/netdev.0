From: robert@herjulf.net
Subject: Re: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 0/5 for
	net-next-2.6
Date: Wed, 25 Nov 2009 17:21:25 +0100
Message-ID: <19213.22917.304623.902855@gargle.gargle.HOWL>
References: <19211.4244.135603.458550@gargle.gargle.HOWL>
	<9929d2390911250018o777405ddk257605e7d0b16d17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1.sys.kth.se ([130.237.32.175]:44272 "EHLO
	smtp-1.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbZKYQrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 11:47:33 -0500
In-Reply-To: <9929d2390911250018o777405ddk257605e7d0b16d17@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher writes:

 > Robert, to help get more eyes on this I have added it to my tree for
 > internal testing and review.

 Fine. The igb patch was tested with a 4-port 82576 board from Interface 
 Masters but they forgot to mount the pull-up resistors for the I2C-bus 
 on my prototype which took some weeks to debug. Anyway there are working 
 boards now.


 About the the Intel brand 82599 board with fixed SFP's. I don't see any DOM 
 support from them. It could be idea check if my reading from I2c is correct.

 Seems I'll have a SFP+ with DOM support soon.

 Cheers

	      	     	       	   	   --ro
