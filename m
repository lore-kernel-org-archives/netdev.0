From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: rstpd implementation
Date: Wed, 22 Jun 2016 12:44:52 -0500
Message-ID: <874m8lqfsb.fsf@x220.int.ebiederm.org>
References: <576A8873.50809@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, <netdev@vger.kernel.org>
To: Phil <pme.neratec@gmx.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <576A8873.50809@gmx.ch> (Phil's message of "Wed, 22 Jun 2016
	14:45:39 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil <pme.neratec@gmx.ch> writes:

> Hi,
>
> When looking for an RSTP daemon I found Stephen Hemminger's
> git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git
> <https://kernel.googlesource.com/pub/scm/linux/kernel/git/shemminger/rstp#zSoyz>
> with it's last commit from October 2011.
>
> Is this implementation still in good use by anybody - or has it been
> replaced/superseded by another implementation?

I don't know and when you get into user space daemons they aren't much
talked about on the kernel lists.  That said you will likely fair better
on the netdev list (cc'd).

Eric
