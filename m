From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] IPV6 Code cleansing
Date: Sun, 24 Aug 2014 22:38:05 -0700 (PDT)
Message-ID: <20140824.223805.107861283242007321.davem@davemloft.net>
References: <1408913592-10630-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbaHYFiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 01:38:07 -0400
In-Reply-To: <1408913592-10630-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Sun, 24 Aug 2014 21:53:09 +0100

> This sequence of patches reduces the number of checkpatch issues in the ipv6
> code. Other than changes to whitespace, there is no change to the code.
> 
> There are no changes to object output as detected by objdump.
> 
> Ian Morris (3):
>   ipv6: White-space cleansing : Line Layouts
>   ipv6: White-space cleansing : Structure layouts
>   ipv6: White-space cleansing : gaps between function and symbol export

Series applied, thanks.
