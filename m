From: Stephen Hemminger <shemminger@osdl.org>
Subject: [BUG] HTB panic
Date: Thu, 15 Jun 2006 09:47:14 -0700
Message-ID: <20060615094714.5785d24a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:22763 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030842AbWFOQri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 12:47:38 -0400
To: Jamal <hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Could some one who has used HTB fix this bug? Looks like a simple use after
free.

http://bugzilla.kernel.org/show_bug.cgi?id=6681
