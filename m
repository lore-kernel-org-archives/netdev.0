From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: IPV6_IPSEC_POLICY / IPV6_XFRM_POLICY socket
 options
Date: Thu, 20 Mar 2003 21:50:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320.215027.95912890.davem@redhat.com>
References: <1048207217.1212.3.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1048207217.1212.3.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 20 Mar 2003 18:40:16 -0600
   
   I've created a patch to fix the problem of racoon not being able to 
   listen on IPv6 addresses.  The problem occurs from not having support 
   for the IP(V6)_IPSEC_POLICY and IP(V6)_XFRM_POLICY socket options in 
   IPv6. 
   
   Please review the patch below and let me know if my fix is ok. 
   
This looks find, I will apply it.
