From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.4.26-pre2] netdevice.h: add netif_msg_init helper
Date: Mon, 08 Mar 2004 21:20:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404D29ED.7050003@pobox.com>
References: <200403081910.i28JAli10587@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200403081910.i28JAli10587@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Please apply the following patch to 2.4.26-pre2
> 
> This patch adds a helper function to initialize the debug bit mask
> for use with netif_msg_*.  When the debug_value is out of range
> it returns the default_msg_enable_bits.  Tested IA32.


Applying to 2.4 and 2.6...  will be after 2.6.4 is released though, 
since this is a new feature and not Release Candidate material.

	Jeff
