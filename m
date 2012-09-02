From: Oliver Neukum <oliver@neukum.org>
Subject: question on ndo_start_xmit()
Date: Sun, 02 Sep 2012 15:39:03 +0200
Message-ID: <6485890.uF7kvdezU7@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:54093 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab2IBNki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 09:40:38 -0400
Received: from linux-lqwf.site (unknown [82.113.106.247])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: neukum_org@smtp-out003.kontent.com)
	by smtp-out003.kontent.com (Postfix) with ESMTPSA id 8C2934000359
	for <netdev@vger.kernel.org>; Sun,  2 Sep 2012 15:40:32 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is it possible that ndo_start_xmit is called with skb==NULL ?

	Regards
		Oliver
