From: Duncan Sands <baldrick@free.fr>
Subject: Re: Oops at __neigh_for_each_release (2.6.9-rc3)
Date: Sat, 2 Oct 2004 09:58:00 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200410020958.01197.baldrick@free.fr>
References: <200410012217.35264.baldrick@free.fr> <20041001135636.0c071602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	laforge@gnumonks.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267344AbUJBIR2@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041001135636.0c071602.davem@davemloft.net>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

> > EIP is at __neigh_for_each_release+0x32/0xb0
> 
> Give this patch a try.  And please report networking bugs
> to netdev@oss.sgi.com in the future, thanks.

OK, will do.  I tested the patch Linus committed - it indeed fixes
the oops.

Thanks a lot!

Duncan.
