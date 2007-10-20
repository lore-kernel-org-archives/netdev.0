From: "Guillaume Chazarain" <guichaz@yahoo.fr>
Subject: Re: PROBLEM: oops, Linus tree: 2.6.23-g4fa4d23f, BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
Date: Sat, 20 Oct 2007 13:32:06 +0200
Message-ID: <3d8471ca0710200432h3607b0a0i9169884ebec3b940@mail.gmail.com>
References: <4719B727.7090908@oak.selfip.net>
	 <Pine.LNX.4.64.0710201246540.18815@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Dave Haywood" <tla@oak.selfip.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Pavel Emelyanov" <xemul@openvz.org>
To: "Jiri Kosina" <jikos@jikos.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765527AbXJTLc3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0710201246540.18815@twin.jikos.cz>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004

This should be fixed in recent git by
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9b013e05e0289c190a53d78ca029e2f21c0e4485

HTH.

-- 
Guillaume
