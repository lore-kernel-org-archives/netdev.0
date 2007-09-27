From: Fabio Souto <fabiomsouto@gmail.com>
Subject: IPSec on Linux Kernel
Date: Thu, 27 Sep 2007 07:04:54 -0700 (PDT)
Message-ID: <12922013.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kuber.nabble.com ([216.139.236.158]:43447 "EHLO
	kuber.nabble.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbXI0OEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 10:04:55 -0400
Received: from isper.nabble.com ([192.168.236.156])
	by kuber.nabble.com with esmtp (Exim 4.63)
	(envelope-from <lists@nabble.com>)
	id 1Iatz4-0002O3-MP
	for netdev@vger.kernel.org; Thu, 27 Sep 2007 07:04:54 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I'm currently doing some research work and I thought that maybe you guys
could help me out on this.
I'm currently trying to find where can I understand more about the IPSec
implementation on the current Linux Kernel (2.6.22). I need to find where
the AH calls are made so I can reroute those functions calls to an external
module, for a safer AH generation.
It would be helpful to find the source code files where I can study the
IPSec stack in detail, and reroute the function call.
Any hints on these topics?

Thanks in advance

Fabio Souto
Portugal
-- 
View this message in context: http://www.nabble.com/IPSec-on-Linux-Kernel-tf4528613.html#a12922013
Sent from the netdev mailing list archive at Nabble.com.

