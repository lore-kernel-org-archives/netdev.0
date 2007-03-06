From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 06 Mar 2007 13:46:16 -0800 (PST)
Message-ID: <20070306.134616.115913845.davem@davemloft.net>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
	<20070306194632.GA28949@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, chris@zankel.net,
	geert@linux-m68k.org, jdike@addtoit.com, rmk@arm.linux.org.uk,
	zippel@linux-m68k.org
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030234AbXCFVqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:46:19 -0500
In-Reply-To: <20070306194632.GA28949@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 6 Mar 2007 19:46:32 +0000

> On Tue, Mar 06, 2007 at 02:42:28AM -0800, akpm@linux-foundation.org wrote:
> 
> > Implement div64_64(): 64-bit by 64-bit division.  Needed by networking (at
> > least).
> 
> Your patch only implements div64_64() for 32-bit MIPS.  Below patch adds
> the trivial 64-bit bits.
> 
>   Ralf
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied to net-2.6.22, thanks Ralf.
