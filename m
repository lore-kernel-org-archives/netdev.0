From: Oliver Neukum <oliver@neukum.org>
Subject: question on netdev_completed_queue()
Date: Thu, 08 Nov 2012 20:38:36 +0100
Message-ID: <1476426.QTHA7ibVHZ@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:45046 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab2KHTic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 14:38:32 -0500
Received: from linux-lqwf.site (91.Red-212-170-18.staticIP.rima-tde.net [212.170.18.91])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: neukum_org@smtp-out003.kontent.com)
	by smtp-out003.kontent.com (Postfix) with ESMTPSA id 4C3064001B75
	for <netdev@vger.kernel.org>; Thu,  8 Nov 2012 20:38:31 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is this function to be called whenever a driver is done with transmitting
data, whether the transmission be successful or not?

	Regards
		Oliver
