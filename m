From: Daniele Lacamera <mlists@danielinux.net>
Subject: Re: [PATCH] TCP Hybla
Date: Sat, 19 Mar 2005 17:59:37 +0100
Message-ID: <200503191759.38103.mlists@danielinux.net>
References: <20050318163123.14969084@dxpl.pdx.osdl.net>
Reply-To: mlists@danielinux.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318163123.14969084@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 19 March 2005 01:31, you wrote:
> Here is a version of TCP Hybla based on the new split out of TCP
> algorithms. It doesn't work right, I probably broke something.

Stephen, please, could you point me to the tree having this new cool 
feature that splits tcp enhancements in separate modules?
I'd like to fix the hybla module and make the necessary experiments.

> Original code for RTT0 was wrong because HZ=1000 on 2.6, so I changed
> it to be a parameter explicitly in ms.
Is this true for any arch?

Regards,

-- 
Daniele Lacamera
root at danielinux.net
