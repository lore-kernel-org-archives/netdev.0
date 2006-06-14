From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: skge wake on lan failing
Date: Wed, 14 Jun 2006 22:10:26 +0100
Message-ID: <pan.2006.06.14.21.10.25.592167@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45749 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S932293AbWFNVPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 17:15:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Fqcha-0004m9-2i
	for netdev@vger.kernel.org; Wed, 14 Jun 2006 23:15:02 +0200
Received: from cpc3-cwma2-0-0-cust739.swan.cable.ntl.com ([81.96.206.228])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 23:15:02 +0200
Received: from sitsofe by cpc3-cwma2-0-0-cust739.swan.cable.ntl.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 23:15:02 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We have a bunch of PCI D-Link System Inc DGE-530T Gigabit Ethernet cards
which use the skge driver. However, the link light for a given card goes
off at the switch during a suspend to ram or power down even though an
"ethtool -s eth0 wol g" has been issued.

Can anyone shed any light on the problem?

-- 
Sitsofe | http://sucs.org/~sits/


