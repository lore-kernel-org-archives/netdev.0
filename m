From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH series][6LoWPAN]
Date: Wed, 2 Nov 2011 19:25:20 +0300
Message-ID: <20111102162520.GA2669@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org,
	jonsmirl@gmail.com
To: davem@davemloft.net, dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39172 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495Ab1KBQ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 12:27:27 -0400
Received: by eye27 with SMTP id 27so298370eye.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 09:27:26 -0700 (PDT)
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

iperf shows about ~40Kbits/sec for TCP :-)

With best regards,
Alexander
