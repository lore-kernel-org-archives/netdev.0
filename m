From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp.c
Date: Mon, 13 Jun 2005 17:00:45 -0700 (PDT)
Message-ID: <20050613.170045.74749212.davem@davemloft.net>
References: <20050613230422.GA7269@gondor.apana.org.au>
	<20050613.162052.41635836.davem@davemloft.net>
	<m1fyvlbyp7.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261164AbVFNAGC@vger.kernel.org>
To: ak@muc.de
In-Reply-To: <m1fyvlbyp7.fsf@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: Tue, 14 Jun 2005 01:53:56 +0200

> Still does, as does x86-64, but actually it could be changed now using
> change_page_attr (and then later undoing it). Is it worth it?

A lot of bootup OOPS's have occured in the past and
were never discovered until someone on a non-x86
platform tested the patch.
