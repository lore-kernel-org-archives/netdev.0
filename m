From: David Miller <davem@redhat.com>
Subject: Re: pull request: batman-adv 20160518
Date: Thu, 19 May 2016 11:51:52 -0700 (PDT)
Message-ID: <20160519.115152.2155102752322148986.davem@redhat.com>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: a@unstable.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbcESSvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 14:51:54 -0400
In-Reply-To: <1463547892-11290-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>
Date: Wed, 18 May 2016 13:04:44 +0800

> these are the fixes that couldn't make it for linux-4.6 rebased on top
> of net-next.
> 
> They were all supposed to be applied on 4.6, therefore it would be nice
> if you could queue them for inclusion in the 4.6.1 stable release.
> 
> Please pull or let me know of any problem!

Pulled, thanks.

> I also have a question: I have another bugfix that should only be
> applied to 4.6 and not to 4.7/net-next - should I directly send it
> to stable@vger.kernel.org ?

Yeah, why don't you send it directly to the stable list.

Thanks.
