From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next]r8169: set bits on Register Interrupt status on
 limit
Date: Thu, 16 Jul 2015 23:44:15 +0200
Message-ID: <20150716214415.GA8407@electric-eye.fr.zoreil.com>
References: <1437041934-2587-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46945 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756461AbbGPVob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 17:44:31 -0400
Content-Disposition: inline
In-Reply-To: <1437041934-2587-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
> Set bits on register Interrupt status on limits by
> configuration(critical).
> On chips not alls bits is in use and some is reserved this patch solve
> this issue.

Did you experience a real bug or is it a theoretical issue ?

I don't mind experimental stuff provided:
- it's tested
- it's explained
- some effort has been done to know what Realtek has to say about it

Call me retentive but the explanations are mildly clear.

-- 
Ueimor
