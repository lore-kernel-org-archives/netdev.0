From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2] pcnet32: Neaten and remove unnecessary OOM messages
Date: Tue, 01 Jul 2014 12:26:53 -0700
Message-ID: <1404242813.14624.15.camel@joe-AO725>
References: <1403550950.15811.15.camel@joe-AO725>
	 <1403557507.20657.3.camel@joe-AO725> <1403740525.28663.6.camel@joe-AO725>
	 <20140701.121935.729962585105477131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140701.121935.729962585105477131.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-07-01 at 12:19 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com> Date: Wed, 25 Jun 2014 16:55:25 -0700
> > Make the code flow a little better for 80 columns.
[]
> > Still depends on patch 1/22: pci-dma-compat: Add pci_zalloc_consistent helper
> 
> If this has a dependency on a patch I'm not added to my tree, I'm not
> applying this one either.

No worries, Andrew picked them up and they are
queued in -next (with the less good subject prefix)
