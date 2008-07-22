From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Tue, 22 Jul 2008 22:13:14 +0200
Message-ID: <48863F5A.9080104@gmail.com>
References: <200807222142.23710.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:30973 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbYGVUNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:13:07 -0400
Received: by fg-out-1718.google.com with SMTP id 19so950710fgg.17
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 13:13:03 -0700 (PDT)
In-Reply-To: <200807222142.23710.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

denys@visp.net.lb wrote, On 07/22/2008 08:42 PM:

> workload: ifb shapers, HTB, nat, 1 e1000, 3 e100 (heavily used only two e100)
> 


Maybe it's unconnected but I'd recommend to try this fresh patch for
possible problems with e1000e vs. netconsole:

http://permalink.gmane.org/gmane.linux.network/100581

Jarek P.
