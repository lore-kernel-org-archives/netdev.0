From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Sat, 18 Jun 2005 16:04:56 -0400
Message-ID: <42B47E68.9020601@pobox.com>
References: <42B456E2.8000500@pobox.com> <Pine.LNX.4.58.0506181047190.2268@ppc970.osdl.org> <Pine.LNX.4.58.0506181105110.2268@ppc970.osdl.org> <Pine.LNX.4.58.0506181112590.2268@ppc970.osdl.org> <42B469B6.2060502@pobox.com> <Pine.LNX.4.58.0506181146260.2268@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262162AbVFRUFG@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0506181146260.2268@ppc970.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> Ok, I ended up re-doing the merge by hand (ie I fetched all the other 
> parts, ignored your top entry, and just merged the previous one manually). 
> 
> I'm pushing out the result now, can you verify that the r8192.c file looks
> like you expected it to look? I think it should be the same thing you
> ended up with except for fixed parents, but...

Looks good here, thanks.

I re-did the merge locally, as a test, finalizing with 'git commit' 
rather than 'git-commit-tree ...' and the parent info came out correct. 
  FWIW.

	Jeff
