From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix broken compilation with
 CONFIG_BNX2X_SRIOV is not set
Date: Fri, 06 Sep 2013 14:47:25 -0400 (EDT)
Message-ID: <20130906.144725.2171542799694168955.davem@davemloft.net>
References: <1378452928-6072-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ariele@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab3IFSr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:47:28 -0400
In-Reply-To: <1378452928-6072-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Fri, 6 Sep 2013 10:35:28 +0300

> Since commit 60cad4e67bd6ff400e7ea61fe762b3042b12ae9d
> "bnx2x: VF RSS support - VF side" fails to compile w/o
> CONFIG_BNX2X_SRIOV option.
>  
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> ---
> Done with same formatting used in the file. 

Applied.
