From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] qlge: Fix early exit from mbox cmd
 complete wait.
Date: Fri, 06 Nov 2009 20:35:32 -0800 (PST)
Message-ID: <20091106.203532.104165750.davem@davemloft.net>
References: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
	<1257529498-17459-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760236AbZKGEfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:35:06 -0500
In-Reply-To: <1257529498-17459-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri,  6 Nov 2009 09:44:57 -0800

> This line was accidentally left out of the previous commit #
> da03945140a035a2962f7f93e359085596f20499.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied, but please provide a text string of the commit's
header line when referencing a commit, don't just provide
the SHA1 ID as that can be not referencable in a -stable
backport.

Here is how I fixed up your commit message so that you can
see how to form it next time, thanks.

qlge: Fix early exit from mbox cmd complete wait.

This line was accidentally left out of the previous commit #
da03945140a035a2962f7f93e359085596f20499 ("qlge: Fix firmware mailbox
command timeout.").

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
