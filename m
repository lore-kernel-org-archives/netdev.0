From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: [Announce] Netchannels ported to the latest git tree. Gigabit benchmark. Complete rout.
Date: Thu, 26 Oct 2006 15:44:37 +0200
Message-ID: <20061026134436.GA22407@outpost.ds9a.nl>
References: <20061020095304.GA22445@2ka.mipt.ru> <20061026105151.GA8325@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:9432 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1161154AbWJZNok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 09:44:40 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20061026105151.GA8325@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 02:51:51PM +0400, Evgeniy Polyakov wrote:

> Benchmark uses 128 bytes sending/receiving per syscall (no latency
> checks, only throughput.
> Receiving CPU usage is 3 times less (90% socket code vs. 30%
> Sending CPU usage is 5 times less (upto 50% vs. upto 10%).

Wow. I currently lack the hardware to reproduce your measurements, do you
have any idea of how these numbers would be with 1024 byte "system calls"?

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
