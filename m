From: "David S. Miller" <davem@davemloft.net>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 23:10:45 -0700 (PDT)
Message-ID: <20050608.231045.48808548.davem@davemloft.net>
References: <42A7268D.9020402@linux.intel.com>
	<20050608.124332.85408883.davem@davemloft.net>
	<200506090903.49295.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, pavel@ucw.cz, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vda@ilport.com.ua
In-Reply-To: <200506090903.49295.vda@ilport.com.ua>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Denis Vlasenko <vda@ilport.com.ua>
Date: Thu, 9 Jun 2005 09:03:49 +0300

> You practically cannot avoid having initrd because you are very likely
> to need to do some wifi config (at least ESSID and mode).

I need neither at home.  It comes up by default just fine with
ifconfig.

Your points are valid, but they do not detract from the fact that
pieced up drivers, half in the kernel half somewhere else, is total
madness.  It is a lose for the user.
