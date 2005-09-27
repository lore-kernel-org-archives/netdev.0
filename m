From: Florin Malita <fmalita@gmail.com>
Subject: Re: [Bonding-devel] Re: [PATCH] channel bonding: add support for
 device-indexed parameters
Date: Tue, 27 Sep 2005 10:10:20 -0400
Message-ID: <20050927101020.6e0b2203.fmalita@gmail.com>
References: <20050927012444.be5d5311.fmalita@gmail.com>
	<200509270711.j8R7BunP014387@death.nxdomain.ibm.com>
	<20050927094055.7953a832.fmalita@gmail.com>
	<1127829269.4560.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, nsxfreddy@gmail.com, akpm@osdl.org,
	davem@davemloft.net, ctindel@users.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750944AbVI0ONu@vger.kernel.org>
To: Eric Paris <eparis@redhat.com>
In-Reply-To: <1127829269.4560.4.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Sep 2005 09:54:29 -0400
Eric Paris <eparis@redhat.com> wrote:

> It dos work with RHEL3.  In modules.conf you just need
[...]
> You can add your mode and mii_mon and such on the options lines.  It
> does work I've used it.

Verified - I completely missed "-o" functionality in insmod & friends.

Sorry for the noise, I'll crawl back under my rock now :)
