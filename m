From: "Alex Aizman" <alex@neterion.com>
Subject: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Tue, 22 Mar 2005 15:29:34 -0800
Message-ID: <200503222330.j2MNU2DD028953@guinness.s2io.com>
Reply-To: <alex@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ak@muc.de>, <jgarzik@pobox.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is our 2nd attempt to submit "xge", the experimental driver for
Neterion, Inc (formerly S2io, Inc) family of 10GbE adapters. 

The "first attempt", along with the still relevant description of features
and motivations, can be looked up at
http://oss.sgi.com/archives/netdev/2005-03/msg00854.html. Note that the xge
driver supports the new 10GbE PCI-X 266MHz adapter.

Changes
======

Removed HAL layering, worked on the coding style to make it compliant with
the kernel style, re-organized the code to accommodate community feedback.

Download
======

A single gzipped patch (filename xge-v.1.1.2870-2.6.11.patch.gz, cksum
2732698831) can be downloaded from: ftp://linuxsrc:opensource@ns1.s2io.com

Signed-off-by: Dmitry Yusupov <dima@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
Signed-off-by: Alex Aizman <alex@neterion.com>
