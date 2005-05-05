From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 17:56:25 -0500
Message-ID: <200505051756.25186.jdmason@us.ibm.com>
References: <20050504230731.12be1bc3.davem@davemloft.net> <20050505153532.30159bd5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505153532.30159bd5.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 05 May 2005 05:35 pm, David S. Miller wrote:
> 
> Is anyone testing this or is everyone too scared? :-)
> 
> A lot of people wanted this TSO stuff fixed, so I spent
> time implementing the fix.  Yet nobody seems interested
> enough to even say "it works" or "it's busted" :-/
 
I can give it a quick sniff on e1000 and r8169 (on amd64), though only to 
verify that its works (ie, no real perf).  Is that acceptable?

Thanks,
Jon
