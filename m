From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2/4] pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Fri, 05 Dec 2003 01:40:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD02853.2070804@pobox.com>
References: <20031203135728.GA13585@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, suparna@in.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: prasanna@in.ibm.com
In-Reply-To: <20031203135728.GA13585@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm applying smc-ultra and tlan patches, but holding off on e100 and e1000.

For both, as Scott mentioned, they don't look tested under NAPI.  For 
e100 specifically, there is a spiffy new e100 that would need to be 
re-diffed and tested against.

	Jeff
