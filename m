From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] subset of RFC2553
Date: Mon, 03 Mar 2003 00:44:57 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.004457.24252283.davem@redhat.com>
References: <1045847170.3104.7.camel@w-bwa1.beaverton.ibm.com>
	<20030221.232639.129509431.davem@redhat.com>
	<1046109300.3503.12.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bwa@us.ibm.com
In-Reply-To: <1046109300.3503.12.camel@w-bwa1.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Bruce Allan <bwa@us.ibm.com>
   Date: 24 Feb 2003 09:54:57 -0800
   
   On Fri, 2003-02-21 at 23:26, David S. Miller wrote:
   > 
   > Bruce, while applying this I noticed that in6addr_{any,loopback}
   > are not exported by modules.
   > 
   > Please send me a small patch to add the exports if this will be
   > needed by SCTP and friends.

   Doh!  Sorry, here (see below) it is against 2.5.59.

Applied, thanks.
