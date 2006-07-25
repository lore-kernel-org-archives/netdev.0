From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 22:31:48 +0400
Message-ID: <20060725183148.GA32566@ms2.inr.ac.ru>
References: <20060719145716.4cb9e7e2@localhost.localdomain> <20060725162001.GA15058@ms2.inr.ac.ru> <20060725085528.38b86319@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:6792 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751472AbWGYScA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 14:32:00 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060725085528.38b86319@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Wouldn't it be better to have a consistent interface (skb always freed),
> and clone the skb if needed for deferred processing?

I am sorry, I misunderstood you. I absolutely agree. It is much better,
the variant which I suggested is a good sample of bad programming. :-)

Alexey

