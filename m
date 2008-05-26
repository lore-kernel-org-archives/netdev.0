From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 26 May 2008 15:15:40 -0700 (PDT)
Message-ID: <20080526.151540.191673092.davem@davemloft.net>
References: <20080526.123338.161271834.davem@davemloft.net>
	<20080526.123951.260448303.davem@davemloft.net>
	<483B239D.4090402@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, matheos.worku@sun.com
To: jesper@krogh.cc
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756246AbYEZWP6@vger.kernel.org>
In-Reply-To: <483B239D.4090402@krogh.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Krogh <jesper@krogh.cc>
Date: Mon, 26 May 2008 22:54:53 +0200

> Applied and running.. I've now pushed 400GB of data through it trying to
> get it to hit the bug but it is still running.
> 
> So without saying that it solved the problem, it definately seems so.
> 2.6.26-rc4 + above patch.

Thanks for testing.
