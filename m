From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Re: IPSec: setkey -DP freezes machine
Date: Mon, 03 Mar 2003 07:23:45 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.072345.99136696.davem@redhat.com>
References: <OFBF1A69FC.8A35D98E-ON86256CDE.0055736B-86256CDE.0055D7BC@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OFBF1A69FC.8A35D98E-ON86256CDE.0055736B-86256CDE.0055D7BC@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Mon, 3 Mar 2003 09:37:37 -0600

   > Tom, would you let me know if this works for you, as my racoon isn't
   > working yet.
   
   The patch works for me, setkey -DP no longer freezes the machine and the
   proper output is displayed.

Thank you for testing.
