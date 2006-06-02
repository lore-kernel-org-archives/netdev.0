From: Stephen Hemminger <shemminger@osdl.org>
Subject: TCP Limited slow start
Date: Fri, 2 Jun 2006 16:13:12 -0700
Message-ID: <20060602161312.3cb2ea66@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30403 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030348AbWFBXNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 19:13:23 -0400
To: Xiaoliang (David) Wei <davidwei79@gmail.com>,
	John Heffner <jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Has anyone done an implementation of RFC3742 for Linux? It looks interesting, but
would need some integration with current ABC code.

There was some evidence of a version in old Web100 code, but it's gone now. Was
it deemed a mistake?
