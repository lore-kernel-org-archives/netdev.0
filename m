From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Update references in two old comments
Date: Sat, 28 Apr 2007 21:21:57 -0700 (PDT)
Message-ID: <20070428.212157.93383979.davem@davemloft.net>
References: <200704271038.08260@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754568AbXD2EVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:21:48 -0400
In-Reply-To: <200704271038.08260@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 27 Apr 2007 10:38:08 +0100

> [TCP]: Update references in two old comments
> 
> This updates references to drafts in comments which must be about 10
> years old.  Internet draft draft-ietf-tcpimpl-prob-03.txt expired in 1998
> and was replaced by RFC 2525 in March 1999.
> 
> Section 3.10 of the draft maps almost identically into section 2.17 of RFC
> 2525: both are entitled "Failure to RST on close with data pending", the
> differences in text body amount to a typo and minor sentence change.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks.
