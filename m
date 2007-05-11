From: stf <stf_polska@o2.pl>
Subject: processes / net connections - an API
Date: Fri, 11 May 2007 14:41:51 +0200
Message-ID: <f21o3o$ri1$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60299 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757664AbXEKMkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 08:40:09 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HmUPi-0001XN-4I
	for netdev@vger.kernel.org; Fri, 11 May 2007 14:40:02 +0200
Received: from nat-mo5.aster.pl ([212.76.37.160])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 14:40:02 +0200
Received: from stf_polska by nat-mo5.aster.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 14:40:02 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I want to write a library or application showing processes and net 
connections. I was looking on ps and netstat to see how those programs 
are retrieving the information. It seems that they are parsing /proc 
entries.

Is there any other kernel API to get information about processes or net 
connections?

Thank you.

