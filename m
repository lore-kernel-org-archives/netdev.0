From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Steps for netdev-2.6 inclusion?
Date: Thu, 02 Dec 2004 01:18:32 -0500
Message-ID: <41AEB3B8.2000406@pobox.com>
References: <41AE7143.80505@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <41AE7143.80505@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's fairly easy, just email me and netdev the patch for inclusion, and 
it'll get reviewed.

Once review issues are addressed, I'll merge it immediately, which 
causes it to be automatically propagated to Andrew Morton's -mm tree for 
testing.

Once consensus agrees that we can push this + HostAP upstream, that's an 
easy 10-minute task.

One potential showstopper is firmware crapola:  I'm concerned about a 
situation where we have drivers in the kernel, but the firmware must be 
downloaded from SourceForge or somesuch.  IOW, the kernel driver as-is 
is useless without a differently-licensed firmware.

Comments?

	Jeff
