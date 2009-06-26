From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [PATCH 2/2]: net: Do software flow seperation on receive.
Date: Sat, 27 Jun 2009 01:40:35 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0906270136390.23295@bizon.gios.gov.pl>
References: <20080917.193442.232214911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1797157929-1246059635=:23295"
Cc: netdev@vger.kernel.org, jens.axboe@oracle.com,
	nickpiggin@yahoo.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:41262 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbZFZX6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 19:58:40 -0400
In-Reply-To: <20080917.193442.232214911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1797157929-1246059635=:23295
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT


Hello,

On Wed, 17 Sep 2008, David Miller wrote:

>
> net: Do software flow seperation on receive.
>
> Push netif_receive_skb() work to remote cpus via flow
> hashing and remove softirqs.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

<CUT>

What is the future of this patch? Was it only a proof of concept or is it 
going to be included in the mainline one day?

Best regards,


 			Krzysztof Olêdzki
---1144830174-1797157929-1246059635=:23295--
