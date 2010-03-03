From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v2 03/10] snet: introduce security/snet, Makefile and Kconfig changes
Date: Wed, 03 Mar 2010 01:23:04 +0100
Message-ID: <m2aauqs17b.fsf@ssh.synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<1267561394-13626-4-git-send-email-sam@synack.fr>
	<20100303000347.GA3017@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Grzegorz Nosek <root@localdomain.pl>
To: Greg KH <greg@kroah.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100303000347.GA3017@kroah.com> (Greg KH's message of "Tue, 2
	Mar 2010 16:03:47 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <greg@kroah.com> writes:

> On Tue, Mar 02, 2010 at 09:23:07PM +0100, Samir Bellabes wrote:
>> this patch creates folder security/snet and adds changes for Kconfig and Makefile
>
> But it breaks the build, as you are referring to files here that are not
> present yet.  Please put this at the end of your patch series to make
> the tree always build for every individual patch.

yes, sure.
thank you Greg

sam
