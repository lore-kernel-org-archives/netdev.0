From: "David S. Miller" <davem@redhat.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Wed, 08 Jan 2003 15:45:16 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030108.154516.123656229.davem@redhat.com>
References: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com>
	<20030108.150638.09647984.davem@redhat.com>
	<3E1CAACB.5D1B82DB@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgrimm2@us.ibm.com
In-Reply-To: <3E1CAACB.5D1B82DB@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jon Grimm <jgrimm2@us.ibm.com>
   Date: Wed, 08 Jan 2003 16:48:43 -0600
   
   IIRC, this is what OpenSS7s SCTP does, while the KAME SCTP manually
   controls the DF bit as per Sridhar's suggestion.   There are tradeoffs
   in either approach.

Then the decision is currently up to you :-)
