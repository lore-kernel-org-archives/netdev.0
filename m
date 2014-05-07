From: David Miller <davem@davemloft.net>
Subject: Re: [patch v] isdn: hisax: remove some dead code
Date: Wed, 07 May 2014 15:44:06 -0400 (EDT)
Message-ID: <20140507.154406.1455843067836633870.davem@davemloft.net>
References: <53668DFC.6040106@bfs.de>
	<20140505085305.GA17365@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, jkosina@suse.cz, rdunlap@infradead.org,
	standby24x7@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, wharms@bfs.de
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140505085305.GA17365@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 May 2014 11:53:05 +0300

> The HISAX_HFC4S8S_PCIMEM code hasn't been able to compile since before
> the start of git history.  I have deleted it.
> 
> There are also a few indenting mistakes where one side of the ifdef
> wasn't indented correctly which I fixed as well.
> 
> Reported-by: Walter Harms <wharms@bfs.de>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: delete the dead ifdefed code.

I'll apply this to net-next, thanks Dan.
