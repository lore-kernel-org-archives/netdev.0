From: Didier Barvaux <didier@barvaux.org>
Subject: Re: [IPv6] policy routing ?
Date: Wed, 6 Apr 2005 22:20:48 +0200
Message-ID: <20050406222048.46c1e997.didier@barvaux.org>
References: <20050406100401.0eab9374.didier@barvaux.org>
	<42543A54.7030504@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <42543A54.7030504@6wind.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


> I beleive policy routing for IPv6 is not yet supported in the kernel.
> FYI a patch is included in the implementation of Mobile IPv6 provided by 
> MIPL: http://www.mobile-ipv6.org/

I have just looked at the patch provided by MIPL. It seems you are right. It adds multiple tables and rule for IPv6 support to the kernel. I will test the MIPL patch tomorrow.

Thank you, Jean-Mickael !

Regards,

Didier Barvaux
