From: Wolfgang Hoffmann <woho@woho.de>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Sun, 26 Feb 2006 09:57:04 +0100
Message-ID: <200602260957.04305.woho@woho.de>
References: <4400FC28.1060705@gmx.net> <20060225180353.5908c955@localhost.localdomain>
Reply-To: woho@woho.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Ian Kumlien <pomac@vapor.com>, Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751281AbWBZIzt@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060225180353.5908c955@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 26 February 2006 03:03, Stephen Hemminger wrote:
> Instead of whining, try this.

I tried and still see the hang.

Stephen, if you want me (as suggested off-list) to bisect the individual 
patches leading from 0.13a to current head, please give me a series of 
patches to incrementally apply, eighter via mail/ftp/git, and I'll test. I 
don't want to hack the patches together myself, because results would be 
worthless if I screw up, and given that I have no networking background 
chances are high ...

It takes me between 5 - 20 GB of data transfer to reproduce the hang, so it 
will take a while, but I'm willing to help. If you see vendor chip specs 
arrive soon and feel it's not worth the hassle, that's fine for me, too.

In the meanwhile, I'll resort to 0.13a

Wolfgang
