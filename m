From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Mon, 5 May 2008 16:01:46 +0200
Message-ID: <BAY103-DAV8BAEA75DC17C9A9C29408B2D70@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758896AbYEEOFJ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Perhaps you could enable SLAB debugging to see if we can get
> closer to the culprit? Alternatively you could try a git bisection.

I don't know if this is the same bug or something else.
This is a different box but same hw/.config

http://www.ussg.iu.edu/hypermail/linux/kernel/0805.0/1969.html
