From: Roman Chertov <roman@santabarbaralabs.com>
Subject: adding IPv6 address in the kernel
Date: Fri, 31 Oct 2008 16:52:43 -0700
Message-ID: <490B9A4B.7040609@santabarbaralabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:52070 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbYJaXwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 19:52:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
    I am trying to create a virtual interface by using new_device kernel 
call.  I would like to be able to specify an IPv6 address for this 
device immediately after its creation in the module code.  I have seen 
an example of how this can be done via the (struct ifreq) and 
devinet_ioctl call for IPv4.  What is the equivalent functionality for IPv6?

Thanks in advance,

Roman
