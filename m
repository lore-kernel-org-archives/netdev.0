From: Rui <wirelesser@gmail.com>
Subject: does intel X520-SR(ixgbe) support RSS on single VLAN?
Date: Mon, 24 Jan 2011 22:18:26 +0800
Message-ID: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59980 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1AXOS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 09:18:27 -0500
Received: by wwa36 with SMTP id 36so4330821wwa.1
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 06:18:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
does intel X520-SR support RSS on single VLAN?

tested with 3 different vlan id and priority packets
What I saw is that all packets were always delivered to the same RxQ.
looks can not get a different RSS index for these packet?
any setting needed?
