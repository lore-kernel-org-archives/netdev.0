From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same
Date: Thu, 03 Oct 2002 06:13:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.061340.91772406.davem@redhat.com>
References: <20021003.060254.26942488.davem@redhat.com>
	<Pine.LNX.4.44.0210031617360.8536-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210031617360.8536-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Pekka Savola <pekkas@netcore.fi>
   Date: Thu, 3 Oct 2002 16:18:53 +0300 (EEST)

   On Thu, 3 Oct 2002, David S. Miller wrote:
   > So does it make no sense at all to have IP_V4ONLY?
   
   Umm, I think an app guy can do that with creating an AF_INET socket; there 
   will not be IPv6 there.  Folks Who Think They Know Best decided that dual 
   use for AF_INET6 would be best, and IPV6_V6ONLY was invented (note: it'd 
   already implemented by some others) to repair that.

Ok, ignore my silly idea then.

Let us continue with verifying correctness of the USAGI
patch.
