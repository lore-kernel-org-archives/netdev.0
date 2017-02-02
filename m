From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: "TCP: eth0: Driver has suspect GRO implementation, TCP performance
 may be compromised." message with "ethtool -K eth0 gro off"
Date: Thu, 2 Feb 2017 12:52:40 +0100
Message-ID: <20170202115240.GH17590@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:47822 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdBBL7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 06:59:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

from time to time I see the following warning in my kernel log:

 TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised.

This happens although I run "/usr/sbin/ethtool -K eth0 gro off" in my
local boot script. 
What is the warning trying to tell me?

-- 
Markus
