From: Brice Goglin <Brice.Goglin@ens-lyon.org>
Subject: [PATCH 0/6] myri10ge updates for 2.6.22
Date: Mon, 07 May 2007 23:48:14 +0200
Message-ID: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:52013 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966354AbXEGVsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Here's some updates of myri10ge for 2.6.22. The good news is that the
aligned-completion whitelist is now gone.

1. support new firmware counters
2. update firmware headers
3. fix restoring of multicast list after reset
4. limit the number of recoveries
5. move the DMA test code into its own function
6. replace the chipset whitelist with firmware autodetection

Thanks!
Brice

