From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next 1/5] net: introduce generic union inet_addr
Date: Mon, 01 Jul 2013 15:00:29 +0800
Message-ID: <1372662029.2974.16.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-2-git-send-email-amwang@redhat.com>
	 <1372353355.2060.22.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Landley <rob@landley.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Veaceslav Falico <vfalico@redhat.com>, Ding@jasper.es
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388Ab3GAHBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 03:01:09 -0400
In-Reply-To: <1372353355.2060.22.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 10:15 -0700, Joe Perches wrote:
> On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> > Cc: Daniel Borkmann <dborkman@redhat.com>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> Hi Cong.
> 
> I think this is premature.
> 
> Please let the discussion and implementation
> for %pI[gS]<foo> play out and be accepted
> into next before using it in other subsystems.
> 
> 

Yeah, I already talked with Daniel off-list, and I agree his %pIS patch
should go first.

(Also I apologized to him for forgetting to credit him when I submitted
this patchset.)
