From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][1/4] b44: Ignore carrier lost errors
Date: Sun, 29 Aug 2004 16:45:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829164528.220424e5.davem@davemloft.net>
References: <200408292218.00756.jolt@tuxbox.org>
	<200408292233.03879.jolt@tuxbox.org>
	<41324158.4020709@pobox.com>
	<200408292304.25447.jolt@tuxbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, pp@ee.oulu.fi, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Schirmer <jolt@tuxbox.org>
In-Reply-To: <200408292304.25447.jolt@tuxbox.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Aug 2004 23:04:24 +0200
Florian Schirmer <jolt@tuxbox.org> wrote:

> Sorry for that. KMail seems to mangle the message as soon as you sign
> it. Please find the non broken versions attached to this mail.

I think Florian's changes are fine.

BTW, can someone fixup something for me?  Update MODULE_AUTHOR()
please :-)  3/4 of this driver have been rewritten since I last
touched it, heh.
