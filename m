From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethertap can use alloc_etherdev
Date: Tue, 11 Nov 2003 19:50:45 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB183E5.1050403@pobox.com>
References: <20031111144557.38bde052.shemminger@osdl.org>	<3FB17650.2000408@pobox.com> <20031111164758.66298833.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031111164758.66298833.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It forces it already several lines later and it hasn't registered yet.


OK.  I applied all but this patch and another one that didn't apply 
cleanly.  Grab the latest net-drivers-2.5-exp patch I just posted, and 
resend against that...

	Jeff
