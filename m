From: "Kalle Pokki" <kalle.pokki@iki.fi>
Subject: Re: Blackfin Ethernet MAC driver compile error
Date: Thu, 4 Oct 2007 17:26:01 +0300
Message-ID: <a425f86c0710040726q27aeb354vbbcb68bd2fed2b76@mail.gmail.com>
References: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
	 <1191489141.6139.1.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:5513 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017AbXJDO0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 10:26:02 -0400
Received: by el-out-1112.google.com with SMTP id v27so48692ele
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2007 07:26:02 -0700 (PDT)
In-Reply-To: <1191489141.6139.1.camel@roc-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/4/07, Bryan Wu <bryan.wu@analog.com> wrote:
> Sorry for missing the pinmux patches.
> After Linus's git-pull, it should be fixed in the latest Linus mainline
> git tree.

Thanks, it is working now. I was also glad to see the binfmt_flat
patch going in.

Do you plan to get the PHY abstraction layer patches for the Blackfin
EMAC included in the upcoming merge window?
