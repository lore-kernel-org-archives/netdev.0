From: gopala krishnan <gopu.0206@gmail.com>
Subject: Re: Flooded with bonding: bond0: doing slave updates when interface is down.
Date: Tue, 13 Apr 2010 07:55:01 +0000 (UTC)
Message-ID: <loom.20100413T095142-137@post.gmane.org>
References: <87mxzj6eyx.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:38184 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab0DMJkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 05:40:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O1cbD-0005Bo-OX
	for netdev@vger.kernel.org; Tue, 13 Apr 2010 11:40:04 +0200
Received: from ABTS-TN-Static-236.54.165.122.airtelbroadband.in ([ABTS-TN-Static-236.54.165.122.airtelbroadband.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:40:03 +0200
Received: from gopu.0206 by ABTS-TN-Static-236.54.165.122.airtelbroadband.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 11:40:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi I have a question, 
Before adding a slave to a bond, is it we require to mave the slave interface
down and add the slave to the bond and make the slave up.
Then the traffic will be disruptive when adding a slave to the bond.


