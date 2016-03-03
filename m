From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 3 Mar 2016 17:18:38 -0500
Message-ID: <56D8B83E.7000303@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <johan@kernel.org>,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45439 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758556AbcCCWSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 17:18:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are using Micrel Phy in one of our board and wondering if we can force the
Phy to disable flow control at start. I have a 1G ethernet switch connected
to Phy and the phy always enable flow control. I would like to configure the
phy not to flow control. Is that possible and if yes, what should I do in the
my Ethernet driver to tell the Phy not to enable flow control?

-- 
Murali Karicheri
Linux Kernel, Keystone
