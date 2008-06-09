From: David Miller <davem@davemloft.net>
Subject: Re: [patch 00/50] 2.6.25.6 -stable review
Date: Sun, 08 Jun 2008 19:26:51 -0700 (PDT)
Message-ID: <20080608.192651.193722134.davem@davemloft.net>
References: <20080608.071051.212882594.davem@davemloft.net>
	<20080608103835.0c0b1e83@osprey.hogchain.net>
	<484C3C13.7020609@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacliburn@bellsouth.net, w@1wt.eu, pupilla@hotmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	chrisw@sous-sol.org
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757774AbYFIC1F@vger.kernel.org>
In-Reply-To: <484C3C13.7020609@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 08 Jun 2008 16:07:47 -0400

> Jay Cliburn wrote:
> > David's admonition tells me I'm doing it wrong, and that I should
> > submit the stable patch to Jeff as well.  Am I right?
> 
> I usually encourage a more-parallel process where you simply email 
> stable@kernel.org with the upstream commit id of the change(s) in question.

Right, and if Jeff wants to work things that way for the
networking drivers that's fine.

Personally, I like to make sure some time passes between when
a fix goes into Linus's tree and when I push it into -stable
because time is often what shakes out the last remaining problems
introduced by some change no matter how seeming obvious the
patch is.
