From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: add a sysctl to reflect the fwmark on replies
Date: Sat, 5 Apr 2014 00:21:04 +0900
Message-ID: <CAKD1Yr3v0pU49dyZj5Cf1n+CMtr-Hz3ODDjVNydbiEo4-nProg@mail.gmail.com>
References: <CAKD1Yr1nGPY131oDrHHHNyhatE3nHFA+Tb4QfVv-mTTHY7B=Yw@mail.gmail.com>
 <1396515601-24880-1-git-send-email-lorenzo@google.com> <20140403121053.GB13354@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:64685 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbaDDPVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 11:21:25 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so1059712igb.9
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 08:21:24 -0700 (PDT)
In-Reply-To: <20140403121053.GB13354@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 3, 2014 at 9:10 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> We share the sysctl namespace for tcp with ipv4, but otherwise the knobs
> are isolated if they touch ip-only behaviour.
>
> Also net-next is currently closed, so the patch would have to wait until it
> opens back up in a few weeks(?).

Ack, thanks. I have an updated patch with two sysctls, but I'll wait
before posting it.
