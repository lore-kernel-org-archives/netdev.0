From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 1/3] net_sched: Add qdisc_enqueue wrapper
Date: Thu, 17 Jul 2008 12:10:50 +0200
Message-ID: <487F1AAA.6050600@trash.net>
References: <20080717100921.3327.3324.stgit@fate.lan> <20080717100927.3327.4197.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51296 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbYGQKKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:10:55 -0400
In-Reply-To: <20080717100927.3327.4197.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> ---
> 
>  include/net/sch_generic.h |    5 +++++
>  net/core/dev.c            |    2 +-
>  net/mac80211/wme.c        |    2 +-
>  net/sched/sch_atm.c       |    2 +-
>  net/sched/sch_cbq.c       |    5 +++--
>  net/sched/sch_dsmark.c    |    2 +-
>  net/sched/sch_hfsc.c      |    2 +-
>  net/sched/sch_htb.c       |    3 +--
>  net/sched/sch_netem.c     |   19 +++++++++++--------
>  net/sched/sch_prio.c      |    3 ++-
>  net/sched/sch_red.c       |    2 +-
>  net/sched/sch_tbf.c       |    3 ++-
>  12 files changed, 30 insertions(+), 20 deletions(-)

This one looks fine.

