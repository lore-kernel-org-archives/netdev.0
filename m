From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge crashes
Date: Wed, 16 Aug 2006 10:57:52 -0700
Message-ID: <20060816105752.717c3d86@localhost.localdomain>
References: <664E3671B2B6DC439E0C9FFCF8E40CA205F500@exchange.I-BNEX>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <olel@ans.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18072 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932161AbWHPR6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 13:58:11 -0400
To: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
In-Reply-To: <664E3671B2B6DC439E0C9FFCF8E40CA205F500@exchange.I-BNEX>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006 19:47:08 +0200
"Beschorner Daniel" <Daniel.Beschorner@facton.com> wrote:

> Stephen,
> 
> the reproducible crashes with all skge versions (where sk98lin works
> fine) on my box are SMP related.
> I booted with maxcpus=1 and the box survived my usual crash test, I will
> keep an eye.
> 
> Daniel
> 

Is this P3 SMP?
What form of IRQ balance are you using?
