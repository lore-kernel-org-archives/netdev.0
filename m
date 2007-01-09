From: David Miller <davem@davemloft.net>
Subject: Re: [GIT][Netlabel] Pull request
Date: Mon, 08 Jan 2007 19:55:13 -0800 (PST)
Message-ID: <20070108.195513.115932473.davem@davemloft.net>
References: <Pine.LNX.4.64.0701081823390.23051@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbXAIDzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 22:55:14 -0500
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0701081823390.23051@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 8 Jan 2007 18:24:41 -0500 (EST)

> The following changes since commit bf81b46482c0fa8ea638e409d39768ea92a6b0f0:
>   Linus Torvalds:
>         Linux 2.6.20-rc4
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-davem
> 
> Paul Moore:
>       NetLabel: correct locking in selinux_netlbl_socket_setsid()
>       NetLabel: correct CIPSO tag handling when adding new DOI definitions
> 
>  net/netlabel/netlabel_cipso_v4.c |    6 +++---
>  security/selinux/ss/services.c   |    4 ++--
>  2 files changed, 5 insertions(+), 5 deletions(-)

Pulled, thanks a lot James.
