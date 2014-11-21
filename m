From: cprasad@cse.iitm.ac.in
Subject: Re: Clarification regarding TCP advertised window
Date: Fri, 21 Nov 2014 13:09:45 +0530 (IST)
Message-ID: <1928355922.134596.1416555585314.JavaMail.root@mail.cse.iitm.ac.in>
References: <1416550823.8629.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iitmpg.iitm.ac.in ([203.199.213.28]:49310 "EHLO
	mail.cse.iitm.ac.in" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbaKUHlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:41:17 -0500
In-Reply-To: <1416550823.8629.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 The exact values are as follows:
tcp_rmem(min,default,max) = (4092 , 87380 , 704512)
The advertised window in the ack packets is ranging from 4092 till around 1,700,000
