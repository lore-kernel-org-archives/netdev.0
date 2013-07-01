From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3] gre: fix a regression in ioctl
Date: Mon, 01 Jul 2013 10:06:07 +0800
Message-ID: <1372644367.2974.7.camel@cr0>
References: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
	 <1372478579-6548-1-git-send-email-amwang@redhat.com>
	 <CAM8tLiP=Y5BM7q3nGzi+J6JGRYTJ8qazpVB-n9+pFhA2ko-+sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519Ab3GACGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 22:06:18 -0400
In-Reply-To: <CAM8tLiP=Y5BM7q3nGzi+J6JGRYTJ8qazpVB-n9+pFhA2ko-+sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 21:42 +0300, Dmitry Kravkov wrote:
> 
> Shouldn't this be addressed in net-tree?

Oh, yeah, I thought only net-next contains that commit...

David, please apply this to net (I tried, the patch can be applied to
net).

Thanks!
