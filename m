From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: -git: Why is drivers/net/wan/hdlc_generic.c:hdlc_setup() exported?
Date: Mon, 26 Jun 2006 21:28:14 +0200
Message-ID: <m3veqnlnsh.fsf@defiant.localdomain>
References: <20060625205137.GH23314@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:56021 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932944AbWFZT2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 15:28:18 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060625205137.GH23314@stusta.de> (Adrian Bunk's message of "Sun, 25 Jun 2006 22:51:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> writes:

>    hdlc_setup() is now EXPORTed as per David's request.
>
> Is a usage of this export pending for the near future

I'm told it is.
-- 
Krzysztof Halasa
