From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 0/9] [RFC] bonding updates for net-next-2.6
Date: Wed, 17 Dec 2008 22:28:27 +0100
Message-ID: <20081217212827.080073908@jonathan.eitzenberger.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61673 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbYLQVaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:30:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

what follows are some bonding updates to 802.3ad mode.  They introduce          
the port_params struct as part of the port struct, which helps in handling      
the port parameter values in various places.                                    
                                                                                
Hopefully they are usefull to you.                                              

Thanks.

  /holger

