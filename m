From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Fix redeclaration of symbol len
Date: Wed, 07 Oct 2009 14:43:37 -0700 (PDT)
Message-ID: <20091007.144337.96104523.davem@davemloft.net>
References: <1254951282-5056-1-git-send-email-hagen@jauu.net>
	<1254951282-5056-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753356AbZJGVnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 17:43:41 -0400
In-Reply-To: <1254951282-5056-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed,  7 Oct 2009 23:34:40 +0200

> Function argument len was redeclarated within the
> function. This patch fix the redeclaration of symbol 'len'.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

In the future please indicate the area you are touching
in the subject line so that it shows up in the header
line of the commit message.  I added "econet: " to your
subject to fix this.

Applied, thanks.
