From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: Fri, 18 Mar 2005 16:09:18 -0800
Message-ID: <423B6DAE.9050803@qualcomm.com>
References: <20050318233637.GS5389@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050318233637.GS5389@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Chris,

Why don't you kill Ethertap completely while you're at it. Ethertap needs "Netlink device emulation"
stuff. And this whole thing has been marked OBSOLETE for more than two years now.
Most projects seem to have switched to TUN/TAP long time ago.

Max
