From: Kumar Gala <galak@kernel.crashing.org>
Subject: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 11:18:52 -0500
Message-ID: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:9984 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753607AbXEJQTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:19:40 -0400
Received: from cpe-24-28-13-126.austin.res.rr.com ([24.28.13.126] helo=[192.168.1.100])
	by nommos.sslcatacombnetworking.com with esmtp (Exim 4.63)
	(envelope-from <galak@kernel.crashing.org>)
	id 1HmBMb-0006WX-BI
	for netdev@vger.kernel.org; Thu, 10 May 2007 11:19:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm wondering how to tell if a given driver/device in the kernel  
supports the ability to bridge between ethernet and 802.11.  From  
searching the web it looks like only the prism driver/device supports  
this.

- k
