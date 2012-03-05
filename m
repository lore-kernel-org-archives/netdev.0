From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Fix licensing problems in if_ppp.h
Date: Sun, 04 Mar 2012 20:41:47 -0500 (EST)
Message-ID: <20120304.204147.652134096643702602.davem@davemloft.net>
References: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jan.kiszka@siemens.com,
	linux-kernel@vger.kernel.org
To: paulus@samba.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Mon, 5 Mar 2012 09:53:37 +1100

> This series of 3 patches is primarily aimed at removing the problem
> that the license on include/linux/if_ppp.h is the old BSD-style license
> with advertising clause.  However, in fact virtually none of that file
> comes from the original PPP code released by CMU.  This series solves
> the problem by moving the code that I originally wrote to a new header
> file with my copyright on it.
> 
> While we're at it, I also change the license on some files where I had
> put an ANU copyright notice originally to have my copyright instead.
> I have an acknowledgement in writing from September 2002 from ANU that
> they do not claim any copyright in this code.

All applied, thanks Paul.
