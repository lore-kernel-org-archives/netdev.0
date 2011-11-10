From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH series][6LoWPAN][net-next]
Date: Thu, 10 Nov 2011 20:32:58 +0300
Message-ID: <20111110173258.GA8056@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbaryshkov@gmail.com, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, jonsmirl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58983 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab1KJRfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 12:35:33 -0500
Received: by wyh15 with SMTP id 15so2983588wyh.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 09:35:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

The following patch series adds both major feature and minor fixes.
Please find detailed description in each of the patches.

Just to summarize current development status:
By using MAC and PHY layers support from
    "http://sourceforge.net/projects/linux-zigbee"
project now it's possible to run generic network applications (ssh, iperf) over
ieee802.15.4 network.

iperf shows about ~40Kbits/sec for TCP 

With best regards,
Alexander
