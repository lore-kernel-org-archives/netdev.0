From: "Matthieu CASTET" <castet.matthieu@free.fr>
Subject: softmac mtu
Date: Sat, 23 Sep 2006 17:50:22 +0000 (UTC)
Message-ID: <ef3s4u$s6s$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:54681 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751370AbWIWRzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 13:55:11 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GRBiQ-0007AW-KZ
	for netdev@vger.kernel.org; Sat, 23 Sep 2006 19:55:02 +0200
Received: from cac94-1-81-57-151-96.fbx.proxad.net ([81.57.151.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 19:55:02 +0200
Received: from castet.matthieu by cac94-1-81-57-151-96.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 19:55:02 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

why softmac (and maybe device using linux 80211 stack) can't increase
their mtu above 1500 ?

IRRC 802.11 allow to send bigger frame. Moreover some driver like airo
allow to use mtu biger than 2000.

thanks,


Matthieu

