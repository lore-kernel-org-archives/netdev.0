From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: PCIe NICs that correctly suspend/resume
Date: Wed, 28 Feb 2007 19:13:01 -0600
Message-ID: <20070228191301.1f46ed3d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf24aec.mail.bellsouth.net ([205.152.59.72]:61103 "EHLO
	imf24aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932887AbXCABNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 20:13:06 -0500
Received: from ibm70aec.bellsouth.net ([70.144.215.109])
          by imf24aec.mail.bellsouth.net with ESMTP
          id <20070301011303.VFAT24557.imf24aec.mail.bellsouth.net@ibm70aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:13:03 -0500
Received: from osprey.hogchain.net ([70.144.215.109])
          by ibm70aec.bellsouth.net with ESMTP
          id <20070301011302.QRKN1602.ibm70aec.bellsouth.net@osprey.hogchain.net>
          for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:13:02 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We're trying to make the Attansic L1 NIC correctly suspend, resume,
and wake-on-lan.  Can someone point me to a PCIe-based NIC driver in
the kernel tree that correctly does these things?  I'd like to see how
it's *supposed* to be done.

Thanks,
Jay
