From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: Re: [Cbe-oss-dev] [PATCH] spidernet: improve interrupt handling
Date: Wed, 11 Jul 2007 13:57:30 +0900 (JST)
Message-ID: <20070711.135730.-1300544419.kouish@swc.toshiba.co.jp>
References: <20070709221922.GP4457@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:49064 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbXGKE5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 00:57:49 -0400
In-Reply-To: <20070709221922.GP4457@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas-san,

> On Mon, Jul 09, 2007 at 05:48:08PM +0900, Ishizaki Kou wrote:
> > We intend this patch to improve spidernet interrupt handling to be
> > more strict.  We had following problem and this patch solves it.
> 
> Looks reasonable to me. I'll forward it upstream. In the future,

Thank you.

> could you use "diff -Nupr"? it adds some extra information
> (the name of the subroutine) to the patch chunks; this makes 
> it easier to read. 

I see. I will do so next time. 

Best regards,
Kou Ishizaki
