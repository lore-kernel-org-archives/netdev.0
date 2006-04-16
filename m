From: "George P Nychis" <gnychis@cmu.edu>
Subject: how to do probabilistic packet loss in kernel?
Date: Sun, 16 Apr 2006 18:44:21 -0400 (EDT)
Message-ID: <4902.128.2.140.224.1145227461.squirrel@128.2.140.224>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.andrew.cmu.edu ([128.2.10.83]:34706 "EHLO
	smtp.andrew.cmu.edu") by vger.kernel.org with ESMTP
	id S1750815AbWDPWoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 18:44:24 -0400
To: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am using iproute2 to setup fowarding, adding routes like "ip route add 192.168.1.3 via 192.168.1.2"

I was wondering where in the kernel I can insert probabilistic packet loss only for forwarded packets?  So that for instance I can drop 5% of all forwarded packets?

I don't need help with the actual code, just need help finding where to insert this code :)

Thanks!
George

