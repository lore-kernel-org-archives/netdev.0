From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] subset of RFC2553
Date: Fri, 21 Feb 2003 23:26:39 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030221.232639.129509431.davem@redhat.com>
References: <3E54128C.327D7759@us.ibm.com>
	<20030219.162129.11584427.davem@redhat.com>
	<1045847170.3104.7.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bwa@us.ibm.com
In-Reply-To: <1045847170.3104.7.camel@w-bwa1.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Bruce, while applying this I noticed that in6addr_{any,loopback}
are not exported by modules.

Please send me a small patch to add the exports if this will be
needed by SCTP and friends.

Thanks.
