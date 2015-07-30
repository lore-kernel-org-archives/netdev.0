From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 30 Jul 2015 10:06:28 +0200
Message-ID: <55B9DB04.4050702@cumulusnetworks.com>
References: <20150730121025.3703e788@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Satish Ashok <sashok@cumulusnetworks.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35401 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbbG3IGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 04:06:32 -0400
Received: by wibxm9 with SMTP id xm9so232940125wib.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 01:06:31 -0700 (PDT)
In-Reply-To: <20150730121025.3703e788@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2015 04:10 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/bridge/br_multicast.c
> 
> between commit:
> 
>   544586f742b4 ("bridge: mcast: give fast leave precedence over multicast router and querier")
> 
> from the net tree and commit:
> 
>   09cf0211f970 ("bridge: mdb: fill state in br_mdb_notify")
> 
> from the net-next tree.
> 
> I fixed it up (hopefully - see below) and can carry the fix as necessary
> (no action is required).
> 

Right, looks good. Thank you!
