From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 11:27:44 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040917112744.190f6f3e.davem@davemloft.net>
References: <20040917062042.GE6523@zax>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, trivial@rustcorp.com.au,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268805AbUIQSbD@vger.kernel.org>
To: David Gibson <david@gibson.dropbear.id.au>
In-Reply-To: <20040917062042.GE6523@zax>
List-Id: netdev.vger.kernel.org


Thanks David, I'll push this upstream asap.

I can't believe in all the route testing I did I never
triggered this on my sparc64 boxes, must have been lucky :(
