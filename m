From: "Pranav" <pranav@nodeinfotech.com>
Subject: HELP NEEDED!!!
Date: Mon, 4 Oct 2004 23:39:04 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BLEAIJDEHOOAGALIAAKBOEDBCCAA.pranav@nodeinfotech.com>
Reply-To: <pranav@nodeinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev-bounce@oss.sgi.com>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi everyone,

            I have got a small problem regarding configuring my ethernet
card,while loading the eth0 driver the kernel performs auto-probing for the
device and configures the eth0 to half-duplex.

I used command line arguments while loading modules
insmod 8139too io=0x280 irq=10 duplex=2

but still it performs the autoprobing overriding the parameters.

Please help me out of this problem,i want to configure my ethernetcard to
fullduplex.

Waiting for a reply...

With Regards,
Pranav.
