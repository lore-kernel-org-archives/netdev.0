From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Tue, 7 Apr 2009 12:16:30 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0904071215111.14639@zuben.voltaire.com>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:18297 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751256AbZDGJQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 05:16:34 -0400
In-Reply-To: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> with 2.6.29 I see that one can either
> 	- vlan a bond (bond0.4001 over bond0 over eth0/1.4001)
> 	- bond vlans (e.g bond0 over eth0/1.4001)

oops, a typo, I wanted to say, one can either
 	- vlan a bond (bond0.4001 over bond0 over eth0/1)
 	- bond vlans (e.g bond0 over eth0/1.4001 over eth0/1)

Or.

