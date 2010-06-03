From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch 1/2]r8169: remove rtl_rw_cpluscmd
Date: Thu, 3 Jun 2010 23:42:57 +0200
Message-ID: <20100603214257.GA3327@electric-eye.fr.zoreil.com>
References: <20100603112428.GC24909@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.185.140-88.rev.gaoland.net ([88.140.185.30]:55001 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754835Ab0FCVt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 17:49:56 -0400
Content-Disposition: inline
In-Reply-To: <20100603112428.GC24909@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang <junchangwang@gmail.com> :
> Some clean up work. Please correct me if any of this is wrong.
> 
> Writting "cmd" back without modification is redundant.
> Secondly, because rtl_rw_cpluscmd is just encapsulation of
> RTL_R16, remove rtl_rw_cpluscmd.

I'll figure that there may be some value in the patch if you
test the change on revision X, Y and Z.

Some cosmetic isolated in a sequence of changes can be fine too.

Otherwise I consider such cleanups as a (useless and) conceivably
harmful distraction.

-- 
Ueimor
