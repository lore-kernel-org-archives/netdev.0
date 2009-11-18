From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Wed, 18 Nov 2009 14:59:36 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0911181455260.2793@localhost.localdomain>
References: <20091118.072506.229926265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757380AbZKRW7f@vger.kernel.org>
In-Reply-To: <20091118.072506.229926265.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 18 Nov 2009, David Miller wrote:
> 
> The following changes since commit 7c9abfb884b8737f0afdc8a88bcea77526f0da87:
>   Linus Torvalds (1):
>         Merge branch 'kvm-updates/2.6.32' of git://git.kernel.org/pub/scm/virt/kvm/kvm
> 
> are available in the git repository at:

Nope, they are not.

I'm not seeing half of it, including these first ones listed (among many 
others):

> Ajit Khaparde (2):
>       be2net: fix to set proper flow control on resume
>       be2net: Bug fix to send config commands to hardware after netdev_register

because I already pulled half of it over a week ago.. You seem to not have 
noticed, possibly because of some confusion?

Anyway, I do seem to get a proper subset, _and_ the stuff I don't get seem 
to be old stuff I already got earlier, so I think everything is fine. But 
you should double-check, because my diffstat/shortlog doesn't match yours 
due to you apparently having included data from previous pull requests..

			Linus
