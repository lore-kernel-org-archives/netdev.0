From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter: netfilter fixes for 2.6.39-rc4
Date: Tue, 19 Apr 2011 12:05:57 -0700 (PDT)
Message-ID: <20110419.120557.245410674.davem@davemloft.net>
References: <1303224705-17400-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693Ab1DSTGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 15:06:31 -0400
In-Reply-To: <1303224705-17400-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Tue, 19 Apr 2011 16:51:42 +0200

> Hi Dave,
> 
> following are three netfilter fixes for 2.6.39-rc4, containing:
> 
> - a fix for the bitmap:ip,mac set type to require the src/dst parameter
>   to be set to src, from Jozsef
> 
> - a fix to make --del-set of the SET target work, from Jozsef
> 
> - a patch to fix the order in which sets are dumped, from Jozsef
> 
> Please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks!
