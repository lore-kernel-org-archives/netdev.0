From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] (10/23) sk98: cleanout unnecessary controller elements
Date: Sat, 13 Nov 2004 20:43:12 -0500
Message-ID: <4196B830.10906@pobox.com>
References: <4192C60A.1050205@designassembly.de>	<20041111154225.5cf85567@zqx3.pdx.osdl.net> <20041111155558.22c8860a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041111155558.22c8860a@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Catchall cleanup patch:
> 	* get rid of obfuscating #define's
> 	* eliminate structure elements in the controller structure
> 	  that are never used or only used in one context or available
> 	  in net_device


I applied patches 1 - 9 to netdev-2.6 queue.

I would prefer that you split up this patch a bit more, and resend that 
(and the rest of this series) in a new patch series.

	Jeff
