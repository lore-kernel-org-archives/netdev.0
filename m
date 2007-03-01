From: Marc D Ronell <mronell@alumni.upenn.edu>
Subject: Network access fails unless tcpdump is running?
Date: Thu, 01 Mar 2007 14:22:24 -0500
Message-ID: <87y7mg4vm7.fsf@corps.glidepath.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59773 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965525AbXCATaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 14:30:18 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HMqyY-0005u3-5B
	for netdev@vger.kernel.org; Thu, 01 Mar 2007 20:30:02 +0100
Received: from pool-71-255-169-178.bstnma.east.verizon.net ([71.255.169.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2007 20:30:02 +0100
Received: from mronell by pool-71-255-169-178.bstnma.east.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2007 20:30:02 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I can not ping a remote host successfully unless I have "tcpdump -i
eth0" running, in which case, my network access works fine.  

I am  running Debian etch on  a Dell Inspiron e1505  laptop.  The eth0
address  is static  on my  local LAN.   Once tcpdump  is  running, the
laptop can access the network with no problems.

Any help or suggestions to solving this concern are really appreciated.

Thanks,

Marc

-- 



