From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: [AX25] inconsistent lock state
Date: Sat, 25 Jun 2011 17:39:42 +0100
Message-ID: <20110625163942.GB20976@linux-mips.org>
References: <4B2CD772.1030106@upmc.fr>
 <201106171536.15660.arnd@arndb.de>
 <20110617135147.GA3470@linux-mips.org>
 <201106171611.10655.arnd@arndb.de>
 <4E06040B.7040309@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org
To: f6bvp <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:57819 "EHLO duck.linux-mips.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750951Ab1FYQjs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 12:39:48 -0400
Content-Disposition: inline
In-Reply-To: <4E06040B.7040309@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 05:51:39PM +0200, f6bvp wrote:

> I applied the patch and since then I could not reproduce the
> inconsistent lock state.
> Thus mkiss patch fixed it.

I also think the patch is the right thing, so

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
