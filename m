From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] FRV: Fix {dis,en}able_irq_lockdep_irqrestore compile error
Date: Wed, 6 Sep 2006 14:50:14 +0200
Message-ID: <20060906125014.GA3978@elte.hu>
References: <20060905132530.GD9173@stusta.de> <20060901015818.42767813.akpm@osdl.org> <5905.1157469663@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54159 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1750874AbWIFM6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 08:58:40 -0400
To: David Howells <dhowells@redhat.com>
Content-Disposition: inline
In-Reply-To: <5905.1157469663@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Howells <dhowells@redhat.com> wrote:

> Fix the lack of certain non-LOCKDEP stub functions in 
> linux/interrupt.h and also provide FRV with LOCKDEP variants.
> 
> This is to be applied to -mm kernel since not all of the functions 
> added exist in the main kernel.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
