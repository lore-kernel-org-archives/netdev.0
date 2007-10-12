From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Also do tc_core_time2big argument (long->unsigned).
Date: Fri, 12 Oct 2007 14:02:44 +0200
Message-ID: <470F6264.5090808@trash.net>
References: <1192189789-23538-1-git-send-email-andreas@fatal.se> <1192190193-23653-1-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56351 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591AbXJLMDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:03:19 -0400
In-Reply-To: <1192190193-23653-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Henriksson wrote:
> tc_core_time2big only used in tc/q_netem.c where it gets passed an unsigned.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  tc/tc_core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)


Seems to be missing a tc_core.h update.
