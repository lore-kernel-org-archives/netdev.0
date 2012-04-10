From: Michal Simek <monstr@monstr.eu>
Subject: axienet driver copyrights
Date: Tue, 10 Apr 2012 13:15:24 +0200
Message-ID: <4F84164C.6000702@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	John Linn <linnj@xilinx.com>,
	David Miller <davem@davemloft.net>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45683 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab2DJLPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 07:15:32 -0400
Received: by eekc41 with SMTP id c41so1289307eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 04:15:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ariane and Daniel, [cc: John Linn, John Williams, David Miller and netdev]

I have several questions about one patch which was added to mainline Linux tree.
Below is information about the patch:

drivers/net/ethernet/xilinx: added Xilinx AXI Ethernet driver
(sha1: 8a3b7a252dca9fb28c23b5bf76c49180a2b60d3b)

The whole driver contains your copyright in 3 files but I don't believe
that you are authors of significant changes to be polite to write there your
copyright.
I really appreciate that someone invested time to add this driver to the mainline
but I am not comfortable that you will be identify as authors of this driver because you are not!

Maintainer for this driver should be Xilinx which has done this driver. I also
see that you have integrated all changes I have done to it. We have done these
changes on Xilinx request to improve the driver stability and performance.

I have spent some time to list your changes you have done to be sure that my
first feeling was wrong but it is not.

There are changes which do nothing with functionality.
1. Clean the driver by checkpatch.pl script.
2. Copy axienet_ior/iow to header file
3. axienet_device_reset resort.

Can you tell me what significant changes you have done in this driver?

I know the whole history of this driver and I have never heard about you
and your changes pointing me that you have just took the latest version
from PetaLogix or Xilinx git repository and use checkpatch.pl script
to fix coding style violations.

I don't think that using checkpatch + 2 simple changes is not enough
to be identified as author.

Can you please correct me?

Thanks,
Michal

David: Would it be possible to ping me everytime when there is any patch
around xilinx ethernet controller. I have all equipment for testing it
and it is my day job to take care about microblaze/xilinx drivers.




-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
