From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches try2] 2.6.x net driver updates
Date: Wed, 25 May 2005 13:48:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0505251200040.2307@ppc970.osdl.org>
References: <4294BD9C.2050105@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261555AbVEYUqz@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4294BD9C.2050105@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 25 May 2005, Jeff Garzik wrote:
>
> Does this work better?

Looks good.

If this was automated, are your changes to git-pull-script generic enough 
to be useful for others, or did you do a totally specialized one for just 
the "lots of heads in the same directory" case?

		Linus
