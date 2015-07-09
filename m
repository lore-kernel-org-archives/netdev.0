From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Disable setting speed outside the ethtool
Date: Fri, 10 Jul 2015 00:21:06 +0200
Message-ID: <20150709222106.GB12705@electric-eye.fr.zoreil.com>
References: <CAGg4U=F=iMgVRAAqk7tkJW_N0Lw8siquYmbWfR=b3sxKz4_63Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57024 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbGIWVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:21:19 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=F=iMgVRAAqk7tkJW_N0Lw8siquYmbWfR=b3sxKz4_63Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marian Corcodel <corcodel.marian@gmail.com> :
> Set speed only on ethtool..Driver is r8169 .

Why ?

You should also elaborate why it's supposed to be regression-free.

-- 
Ueimor
