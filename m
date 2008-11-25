From: David Schweikert <david@schweikert.ch>
Subject: niu: ethtool -s support?
Date: Tue, 25 Nov 2008 14:35:30 +0100
Message-ID: <20081125133530.GA1633@schweikert.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.schweikert.ch ([88.198.52.145]:44998 "EHLO
	mail.schweikert.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYKYN7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 08:59:05 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.schweikert.ch (Postfix) with ESMTP id C09CB12DAE7
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 14:35:34 +0100 (CET)
Received: from mail.schweikert.ch ([127.0.0.1])
	by localhost (mail.schweikert.ch [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jBLlkPsB3DrP for <netdev@vger.kernel.org>;
	Tue, 25 Nov 2008 14:35:30 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It is apparently not possible to set the link parameters on a niu
interface (speed, duplex mode, auto-negotiation) with ethtool.
Is support for it planned?

Thanks
David
