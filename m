From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.4.26-rc3]pcnet32 fix hang/crash with loopback test
Date: Mon, 19 Apr 2004 12:51:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40840387.40605@pobox.com>
References: <200404132208.i3DM8BB01509@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200404132208.i3DM8BB01509@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> If the pcnet32 interface is not up, running the loopback test may hang or
> crash the system.  This patch provided by Jim Lewis fixes that problem.
> Tested on ia32 and ppc systems.  This applies cleanly against net-drivers-2.4


applied to 2.4
