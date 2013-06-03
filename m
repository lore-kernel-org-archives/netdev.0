From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Mon, 3 Jun 2013 08:15:08 -0700
Message-ID: <20130603081508.5f450920@nehalam.linuxnetplumber.net>
References: <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>
	<20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
	<OF0BD0286F.81969B78-ON85257B74.00097DBA-85257B74.000C5443@us.ibm.com>
	<20130602.224037.1086892379998889821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:40091 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758040Ab3FCPPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:15:12 -0400
Received: by mail-pb0-f51.google.com with SMTP id um15so2696907pbc.38
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:15:12 -0700 (PDT)
In-Reply-To: <20130602.224037.1086892379998889821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Jun 2013 22:40:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> I'm deciding to keep the patch in, and not revert.
> 
> A very concise and incredibly strong argument will need to be
> given to me to change my mind.
> 
> Thanks.

Ok, I decided to drop the ability to configure this in 3.10 iproute2 because
the behaviour changes in 3.11
