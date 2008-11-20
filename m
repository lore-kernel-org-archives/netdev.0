From: Kunsheng Chen <linux_kernel_chan@yahoo.com>
Subject: Is there any function similar to inet_ntoa() in Kernel or NetFilter ?
Date: Wed, 19 Nov 2008 16:03:52 -0800 (PST)
Message-ID: <192580.22596.qm@web111104.mail.gq1.yahoo.com>
Reply-To: linux_kernel_chan@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n20.bullet.mail.mud.yahoo.com ([68.142.206.147]:41710 "HELO
	n20.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751092AbYKTADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 19:03:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, everyone,

I am doing a project similar to iptable using netfilter, currently I want to convert a IP address from 'long int' back to dotted address.

I don't know whether there is some functions inside kernel or netfilter that could make that like using inet_ntoa() in <arpa/inet.h>


Any idea is well appreciated.


Thanks,

Kunsheng


      

