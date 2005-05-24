From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Mon, 23 May 2005 23:50:36 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0505232349020.2307@ppc970.osdl.org>
References: <4292BA66.8070806@pobox.com> <Pine.LNX.4.58.0505232253160.2307@ppc970.osdl.org>
 <4292CB01.6090506@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Netdev <netdev@oss.sgi.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4292CB01.6090506@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 24 May 2005, Jeff Garzik wrote:
> 
> You really can't beat
> 
> 	cp .git/refs/heads/master .git/refs/heads/new-branch
> 
> as the fastest way to create a new branch off the tip.

So? It's the fastest, but it's also BROKEN. Exactly because the way you do 
things, the merge messages are meaningless.

So fix your merge messages. 

		Linus
