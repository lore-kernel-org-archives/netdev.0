From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Fri, 28 Jul 2006 16:11:54 +0200
Message-ID: <m3slklq0np.fsf@defiant.localdomain>
References: <m3zmevqhgn.fsf@defiant.localdomain>
	<20060727164334.GA2779@ms2.inr.ac.ru>
	<m3ac6vx8ik.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50104 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1161171AbWG1OL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 10:11:58 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <m3ac6vx8ik.fsf@defiant.localdomain> (Krzysztof Halasa's message of "Thu, 27 Jul 2006 19:28:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa <khc@pm.waw.pl> writes:

> Are you sure about that? It would mean almost devices, including
                                         ^^^^^^^^^^^^^^
> Ethernet, are at risk:

"almost all devices", of course.
-- 
Krzysztof Halasa
