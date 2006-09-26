From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Generic HDLC update
Date: Tue, 26 Sep 2006 23:35:44 +0200
Message-ID: <m3ac4m1fbj.fsf@defiant.localdomain>
References: <m3odt21hs5.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	PC300 Maintainer <pc300@cyclades.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:27273 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S964828AbWIZVfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 17:35:45 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <m3odt21hs5.fsf@defiant.localdomain> (Krzysztof Halasa's message of "Tue, 26 Sep 2006 22:42:34 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

The first patch renames drivers/net/wan/hdlc_generic.c file to hdlc.c.
It has been generated with git-diff* -M. Please let me know if you
need a "normal" patch.
-- 
Krzysztof Halasa
