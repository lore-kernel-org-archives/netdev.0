From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.4 released
Date: Mon, 3 Aug 2009 16:18:49 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0908031615570.10156@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: radvd-devel-l@litech.org
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54855 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911AbZHCNSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 09:18:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A new version of radvd has been released.  This just fixes an 
unintentional change in 1.3: RAs were accidentally often unicast to 
solicitors instead of being multicast. This is still compliant with 
the specification but is not optimal.

Thanks to Ninad Adi, Elitecore Technologies/Cyberoam UTM for finding 
and reporting the problem found in IPv6 Ready testing.

Get it at: http://www.litech.org/radvd/

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

