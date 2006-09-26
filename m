From: Paul Mackerras <paulus@samba.org>
Subject: Re: Subject: [PATCH] Advertise PPPoE MTU (resubmit).
Date: Tue, 26 Sep 2006 23:37:31 +1000
Message-ID: <17689.11547.179460.127518@cargo.ozlabs.ibm.com>
References: <11592702983561-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:16599 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751439AbWIZNjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 09:39:01 -0400
To: mostrows@earthlink.net
In-Reply-To: <11592702983561-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mostrows@earthlink.net writes:

> PPPoE must advertise the underlying device's MTU via the ppp channel
> descriptor structure, as multilink functionality depends on it.
> 
> Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>

Acked-by: Paul Mackerras <paulus@samba.org>
