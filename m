From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Fri, 26 Nov 2010 09:13:55 -0800
Message-ID: <AANLkTi=8smjJgTXxe7vj8AHAMceLUr25KurZbm07vP1j@mail.gmail.com>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	<20101124.114534.15255941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:53021 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab0KZRN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 12:13:59 -0500
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oAQHDwM6030456
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 09:13:58 -0800
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by hpaq11.eem.corp.google.com with ESMTP id oAQHDuB6011065
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 09:13:56 -0800
Received: by pvd12 with SMTP id 12so384973pvd.6
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 09:13:55 -0800 (PST)
In-Reply-To: <20101124.114534.15255941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Applied, please consider Eric's feedback about map NUMA node placement.

Yes, I intended to do that.  Also, I was planning to add Changli's
idea of adding CONFIG_XPS.  Also, I believe the case where CONFIG_RPS
is not enabled breaks the build, I'll send a fix as soon as possible.

Tom
