From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 23:13:19 -0700 (PDT)
Message-ID: <20050608.231319.95056824.davem@davemloft.net>
References: <42A7268D.9020402@linux.intel.com>
	<20050608.124332.85408883.davem@davemloft.net>
	<42A7DC4D.7000008@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, vda@ilport.com.ua, pavel@ucw.cz,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <42A7DC4D.7000008@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 09 Jun 2005 02:06:05 -0400

> Therefore, the easiest way to make things work today is to poke Intel to 
> fix their firmware license so that we can distribute it with the kernel :)

Seperate firmware from the in-kernel driver is a big headache for
users.  As DaveJ has stated, people make mistakes and try to match up
the wrong firmware version with the driver and stuff like that.  And
he should know as he has to deal sift through bogus bug reports from
people running into this problem.

If it's integrated, there are no problems like this.
