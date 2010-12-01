From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Wed, 1 Dec 2010 11:27:16 -0800
Message-ID: <20101201112716.783af7c7@nehalam>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
	<20101201103802.11464029@nehalam>
	<20101201.104823.59686720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	tgraf@infradead.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39937 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851Ab0LAT1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 14:27:18 -0500
In-Reply-To: <20101201.104823.59686720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Dec 2010 10:48:23 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 1 Dec 2010 10:38:02 -0800
> 
> > Ok. but will not be applied until after 2.6.38 (when kernel support
> > is upstream).
> 
> Speaking of which, Stephen could you please process the iproute2 patches
> which have been rotting in the patchwork queue since... May?!
> 
> Just reject them if you don't plan to apply them.  Letting them just sit
> around there for half a year bothers me (and patch submitters) a lot.
> 

Now up to date with 2.6.37-rcX in git tree.

