From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 16/29] netvm: INET reserves.
Date: Fri, 14 Dec 2007 13:10:27 -0800
Message-ID: <200712141310.27690.phillips@phunq.net>
References: <20071214153907.770251000@chello.nl> <20071214154441.337409000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phunq.net ([64.81.85.152]:54172 "EHLO moonbase.phunq.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689AbXLNVKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:10:31 -0500
In-Reply-To: <20071214154441.337409000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

sysctl_intvec_fragment, proc_dointvec_fragment, sysctl_intvec_fragment 
seem to suffer from cut-n-pastitis.

Regards,

Daniel
