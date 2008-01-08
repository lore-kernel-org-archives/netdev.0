From: David Miller <davem@davemloft.net>
Subject: my NAPI patches
Date: Tue, 08 Jan 2008 15:08:48 -0800 (PST)
Message-ID: <20080108.150848.116653308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752532AbYAHXIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 18:08:48 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 27DF9C8C188
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2008 15:08:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Can people do me a favor and do more constructive things like test
that my patches really do fix the "device down during packet flood"
bug instead of nit-picking all the individual driver fixups I made?

That's what is useful at this time, thanks.
