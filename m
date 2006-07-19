From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Wed, 19 Jul 2006 13:01:50 -0700 (PDT)
Message-ID: <20060719.130150.39158599.davem@davemloft.net>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
	<20060719155204.0de8882b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37318
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030265AbWGSUBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 16:01:49 -0400
To: shemminger@osdl.org
In-Reply-To: <20060719155204.0de8882b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 19 Jul 2006 15:52:04 -0400

> As a related note, I am looking into fixing inet hash tables to use RCU.

IBM had posted a patch a long time ago, which would be not
so hard to munge into the current tree.  See if you can
spot it in the archives :)
