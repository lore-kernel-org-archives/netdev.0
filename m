From: Jeff Garzik <jgarzik@pobox.com>
Subject: [RFT] acenic net driver
Date: Fri, 14 May 2004 13:20:13 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A4FFCD.7040704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261798AbUENRU2@vger.kernel.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org


Christoph was kind enough to convert acenic to use the PCI API.

Can someone with an acenic card download Andrew Morton's -mm tree (which 
contains Christoph's work), and verify that the driver still works?

Nothing elaborate required, just wanted to make sure nothing was broken 
in the conversion to PCI API.

Thanks,

	Jeff
