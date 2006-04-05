From: Dave Kleikamp <shaggy@austin.ibm.com>
Subject: Re: [PATCH] [IPSEC] Avoid null pointer dereference in
	xfrm4_rcv_encap
Date: Wed, 05 Apr 2006 10:41:57 -0500
Message-ID: <1144251717.10336.18.camel@kleikamp.austin.ibm.com>
References: <1144249178.10340.5.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751113AbWDEPmW@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1144249178.10340.5.camel@kleikamp.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Never mind.  Somehow I missed Herbert's patch for this in the netdev
archives.
-- 
David Kleikamp
IBM Linux Technology Center
