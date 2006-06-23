From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge - drop 2 workarounds that have been fixed in the PCI core
Date: Thu, 22 Jun 2006 21:10:44 -0400
Message-ID: <20060623011043.GA18234@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:9177 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932110AbWFWBKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 21:10:45 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following 2 patches remove 2 workarounds that were in myri10ge until
the PCI core included a nice fix, which is the case now.

[PATCH] myri10ge - drop workaround for the missing AER ext cap on nVidia CK804
[PATCH] myri10ge - drop workaround pci_save_state() disabling MSI

Please apply.

Thanks,
Brice Goglin

