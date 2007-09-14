From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network Namespace status
Date: Fri, 14 Sep 2007 03:33:39 -0600
Message-ID: <m1zlzp3824.fsf@ebiederm.dsl.xmission.com>
References: <m18x7a5qif.fsf@ebiederm.dsl.xmission.com>
	<46EA244C.1050702@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58175 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbXINJgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 05:36:23 -0400
In-Reply-To: <46EA244C.1050702@hartkopp.net> (Oliver Hartkopp's message of
	"Fri, 14 Sep 2007 08:03:56 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <oliver@hartkopp.net> writes:

> can you send me your current AF_PACKET patch? I just want to update our
> recent post of the CAN (controller area network) subsystem (AF_CAN)
> which is (in some parts) similar to AF_PACKET. So i can take a look on
> it to provide the latest technique in the next post ...

Ok the last snapshot of my tree is at:

git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git
And tagged as: netns/v2.6.23-rc5netns45

Although that is the same as the default HEAD until I rebase my tree
again.

Eric
