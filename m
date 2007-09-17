From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] SCTP: Implement SCTP-AUTH internals
Date: Sun, 16 Sep 2007 19:29:00 -0700 (PDT)
Message-ID: <20070916.192900.02302804.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897954993782-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbXIQC3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:29:00 -0400
In-Reply-To: <11897954993782-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:53 -0400

> This patch implements the internals operations of the AUTH, such as
> key computation and storage.  It also adds necessary variables to
> the SCTP data structures.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, with lots of trailing whitspace fixed.

Please check your patches with GIT by using something such
as "git apply --check --whitespace=error-all foo.diff"
in the future, and you'll see stuff like this:

Adds trailing whitespace.
diff:696:	
Adds trailing whitespace.
diff:732:	return secret; 
Adds trailing whitespace.
diff:805:	
Adds trailing whitespace.
diff:815:/* 
Adds trailing whitespace.
diff:1034:			break; 
Adds trailing whitespace.
diff:1098:		
Adds trailing whitespace.
diff:1109:	    
fatal: 7 lines add trailing whitespaces.

Thanks.
