From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH,RFT] 8139cp TSO support
Date: Mon, 30 Aug 2004 23:52:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830215227.GA23857@electric-eye.fr.zoreil.com>
References: <20040829212205.GA2864@havoc.gtf.org> <20040829222831.GA9496@electric-eye.fr.zoreil.com> <41326079.9090402@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41326079.9090402@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> You definitely want to set .len on the no-frags path...

Oops.. Patch follows.

I won't have a neat tso enabled r8169 driver today. Something goes wrong.

--
Ueimor
