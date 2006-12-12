From: Kumar Gala <galak@kernel.crashing.org>
Subject: examples of setting ip address/netmask/etc.. on a device
Date: Tue, 12 Dec 2006 15:01:53 -0600
Message-ID: <A02AEA26-70F9-4B55-A88A-235B3FF4C9F9@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:24539 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932846AbWLLVB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 16:01:59 -0500
Received: from rrcs-71-41-17-31.sw.biz.rr.com ([71.41.17.31] helo=[192.168.3.103])
	by nommos.sslcatacombnetworking.com with esmtp (Exim 4.52)
	id 1GuEkv-0004gO-02
	for netdev@vger.kernel.org; Tue, 12 Dec 2006 15:01:41 -0600
To: Netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was wondering if there were any examples of net devices that expect  
to be told the ip information for their connection (things doing  
forms of offload).  If so can someone point me at a driver that does  
this.

- kumar
