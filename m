From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: setkey -DP freezes machine
Date: Mon, 03 Mar 2003 01:34:51 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.013451.20307573.davem@redhat.com>
References: <OF2046BAB2.15FCD4CE-ON86256CDA.006CD0E3-86256CDA.0078C74D@pok.ibm.com>
	<Pine.LNX.4.44.0303010205360.27480-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0303010205360.27480-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Sat, 1 Mar 2003 03:01:04 +1100 (EST)
   
   Alternatively, a family parameter could be added to the compile_policy() 
   operation, but this duplicates data already present in our native 
   xfrm_userpolicy_info format.

I like this solution, it seems the cleanest.

Could someone implement this fix and send me the patch?
I'm very backlogged for the next day or so...
