From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 0/2] Two more pasemi_mac patches for 2.6.26
Date: Tue, 25 Mar 2008 20:56:25 -0500
Message-ID: <20080326015625.GA23103@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, pasemi-linux@ozlabs.org,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:42042 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbYCZBr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 21:47:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

The below two patches go on top of the previous patches that were acked
by you but applied to pasemi.git for feed up through powerpc.git.

One is a couple of fixes for various corner cases in the jumbo support
configuration. The second is addition of netpoll support, from Nate
Case.

Review/ack would be appreciated, I'll feed them up the same path as the
other changes.


-Olof
