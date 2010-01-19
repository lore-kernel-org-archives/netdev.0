From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3 driver / BCM5722 dropping to 10Base-HD
Date: Tue, 19 Jan 2010 15:08:27 -0800
Message-ID: <20100119230827.GA23501@xw6200.broadcom.net>
References: <3b2bc9d1001180617m8c2e8ddm2bc99099758e53c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "marco gaddoni" <marco.gaddoni@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3597 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab0ASXIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 18:08:36 -0500
In-Reply-To: <3b2bc9d1001180617m8c2e8ddm2bc99099758e53c3@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2010 at 06:17:32AM -0800, marco gaddoni wrote:
> Hello,
> 
> i have a dell with a BCM5722 driven by the tg3 driver.
> 
> this pc is connected to an unmanaged switch by micronet;
> the connection is at 1000MBs.
> 
> the system is normally stable;
> sometimes the connection get dropped to 10Mbs/HD.
> 
> i can get te connection back up to 1000Mbps
> with an ethtool -t eth0.
> 
> do you have any idea on what is the cause of this ?
> is this the wrong adderess?
> 
> please cc: me as i am not subscibed to netdev.
> 
> thank you in advance,
>  marco,

Can you post the driver messages from the syslog and the output of
ethtool -i eth0?

