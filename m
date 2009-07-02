From: David Miller <davem@davemloft.net>
Subject: Re: [9P PATCH 2/2] net/9p: Fix crash due to bad mount parameters.
Date: Thu, 02 Jul 2009 13:18:33 -0700 (PDT)
Message-ID: <20090702.131833.250097602.davem@davemloft.net>
References: <1246474254-10401-1-git-send-email-adkulkar@umail.iu.edu>
	<1246474254-10401-2-git-send-email-adkulkar@umail.iu.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org
To: adkulkar@umail.iu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755207AbZGBUS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 16:18:27 -0400
In-Reply-To: <1246474254-10401-2-git-send-email-adkulkar@umail.iu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Date: Wed,  1 Jul 2009 12:50:54 -0600

> It is not safe to use match_int without checking the token type returned
> by match_token (especially when the token type returned is Opt_err and
> args is empty). Fix it.
> 
> Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>

Applied.
