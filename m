From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: When will net-next merge with linux-next?
Date: Mon, 14 Mar 2016 09:21:39 -0700
Message-ID: <20160314162139.GA2925@kroah.com>
References: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39727 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbcCNQVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 12:21:40 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 06:09:41AM +0000, Dexuan Cui wrote:
> Hi David,
> I have a pending patch of the hv_sock driver, which should go into the
> kernel through the net-next tree:
> https://lkml.org/lkml/2016/2/14/7
> 
> The VMBus side's supporting patches of hv_sock have been in Greg's tree
> and linux-next for more than 1 month, but they haven't been in net-next
> yet, I suppose this is because of the releasing of 4.5.
> 
> Now 4.5 is released. Will you merge with Greg's tree or linux-next?

linux-next is a merge of all of the maintainer's trees, and it is
rebased every day, it's impossible to merge that back into a maintainers
tree, sorry.

> I read netdev-FAQ.txt, but still don't have a clear idea about how things
> work in my case.

Try reading Documentation/development-process/ please.  Things will get
merged together into Linus's tree over the next 2 weeks as we ask him to
pull our trees.

thanks,

greg k-h
