From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Implement IP_UNICAST_IF socket option.
Date: Wed, 01 Feb 2012 14:39:13 -0500 (EST)
Message-ID: <20120201.143913.52085939693600862.davem@davemloft.net>
References: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
	<20120201.141232.458020616314562146.davem@davemloft.net>
	<CAEU2+vpDT5ZVAXmXf5VbNTiyEKbs9KG2b6oPr=cPDHQfBjyxkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ehoover@mines.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab2BATjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:39:16 -0500
In-Reply-To: <CAEU2+vpDT5ZVAXmXf5VbNTiyEKbs9KG2b6oPr=cPDHQfBjyxkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Erich E. Hoover" <ehoover@mines.edu>
Date: Wed, 1 Feb 2012 12:32:54 -0700

> On Wed, Feb 1, 2012 at 12:12 PM, David Miller <davem@davemloft.net> wrote:
>> ...
>> I see no value in exporting a different API than what other systems
>> use, especially if you are adding this interface exactly for providing
>> support for WINE applications, so please don't do this thing with
>> argument sizes and ip_mreqn.
> 
> I didn't intend to export the API differently, I clearly misread the
> article on MSDN.  If I revise this patch to require an interface index
> is there any chance it will be considered for inclusion?

Yes.
