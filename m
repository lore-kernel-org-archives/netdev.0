From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: [patch 0/3] Add tsi108 On chip Ethernet device driver support
Date: 12 Sep 2006 16:55:15 +0800
Message-ID: <1158051315.14448.91.camel@localhost.localdomain>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:36517 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1751376AbWILIzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 04:55:31 -0400
To: Andrew Morton <akpm@osdl.org>, jgarzik <jgarzik@pobox.com>
In-Reply-To: <1157962200.10526.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that my previous patch was blocked because of the size :-).
This serial of patches add tsi108/9 on chip Ethernet controller support.

1/3 : Config and Makefile modification.
2/3 : Header file
3/3 : C file

Roy

