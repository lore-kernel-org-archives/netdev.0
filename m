From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: how to set pppoe source mac address?
Date: Fri, 19 Jan 2007 16:03:38 +0100
Message-ID: <F6AD7E21CDF4E145A44F61F43EE6D939C68D1D@tmnt04.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from 147.175.241.83.in-addr.dgcsystems.net ([83.241.175.147]:33373
	"EHLO tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965201AbXASPDl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 10:03:41 -0500
Content-Class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have several pppoe i/f's over one eth0 i/f and I want to set the
source mac address used by each pppoe i/f to a unique mac address from
user space.

Is this possible? If so, how do I do that?

 Jocke
