From: David Miller <davem@davemloft.net>
Subject: Re: query: net-next section mismatch(es)
Date: Sun, 08 Nov 2009 16:35:27 -0800 (PST)
Message-ID: <20091108.163527.185100796.davem@davemloft.net>
References: <4AF6D1F5.80307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751092AbZKIAfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 19:35:01 -0500
In-Reply-To: <4AF6D1F5.80307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sun, 08 Nov 2009 09:13:09 -0500

> Yesterday morning (and for a month), I was getting the usual:
> 
>   WARNING: modpost: Found 1 section mismatch(es).
>   To see full details build your kernel with:
>   'make CONFIG_DEBUG_SECTION_MISMATCH=y'
> 
> This morning, it changed:
> 
>   WARNING: modpost: Found 4 section mismatch(es).
>   To see full details build your kernel with:
>   'make CONFIG_DEBUG_SECTION_MISMATCH=y'
> 
> I remember compiling it once with that option, and not finding
> anything
> wrong in my code, but I'm wondering how it took a great leap?

Well, type 'make CONFIG_DEBUG_SECTION_MISMATCH=y' as the message
says, in order to find out.
