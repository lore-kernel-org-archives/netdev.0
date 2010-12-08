From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [v3 PATCH 2/2] netpoll: remove IFF_IN_NETPOLL flag
Date: Wed, 8 Dec 2010 16:49:38 +0800
Message-ID: <AANLkTikdweTkcsxTgf+phRaHYWMb9eAwrtr1xJr+0C1s@mail.gmail.com>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain>
 <20101208075218.5792.64791.sendpatchset@localhost.localdomain>
 <AANLkTindQMNKhC2aowUyjm=uO8gFKqOOPa9HXSU1q7Gh@mail.gmail.com> <4CFF437D.1060904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:58240 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954Ab0LHIuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 03:50:00 -0500
In-Reply-To: <4CFF437D.1060904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 8, 2010 at 4:36 PM, Cong Wang <amwang@redhat.com> wrote:
>
> A few lines above that code said:
>
> /* Private (from user) interface flags (netdevice->priv_flags). */
>
> unless this comment is wrong, we don't need to worry.
>

It seems these macros are exported to user space wrongly.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
