From: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
Subject: Re: [PATCH] IPV6 : segmentation offload not set correctly on TCP children
Date: Sat, 26 Aug 2006 01:06:26 +0200
Message-ID: <20060825230626.GC4570@cip.informatik.uni-erlangen.de>
References: <20060821212243.GA1558@cip.informatik.uni-erlangen.de> <20060821150231.31a947d4@localhost.localdomain> <20060821222634.GC21790@cip.informatik.uni-erlangen.de> <20060825154353.3ecaf508@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:55943 "EHLO
	faui03.informatik.uni-erlangen.de") by vger.kernel.org with ESMTP
	id S964806AbWHYXG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:06:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060825154353.3ecaf508@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,
thanks for the fix, it fixes the problem for me. I closed the bug. On
which hardware did you reproduce the bug and how did you found it? Did
you use git bisect?

        Thomas
