From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: Macro mismatch in test tree
Date: Tue, 13 May 2008 12:04:38 +0100
Message-ID: <20080513110438.GA30798@gerrit.erg.abdn.ac.uk>
References: <48294E9C.4060209@cn.fujitsu.com> <20080513083033.GA11707@gerrit.erg.abdn.ac.uk> <48296623.8040405@cn.fujitsu.com> <20080513103218.GA28532@gerrit.erg.abdn.ac.uk> <482972E5.8060703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:44001 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751747AbYEMLEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 07:04:44 -0400
Content-Disposition: inline
In-Reply-To: <482972E5.8060703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The first dccp_feat_print_opt() take 5 parameters when  
> CONFIG_IP_DCCP_DEBUG, but the second one just take 4.
>
Thanks :) Fixed.
