From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: IPv6 random failures
Date: Fri, 23 May 2003 13:50:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030523.135055.104051001.davem@redhat.com>
References: <OFD45FE8D2.BE223435-ON86256D2F.004DFD33-86256D2F.005647E2@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OFD45FE8D2.BE223435-ON86256D2F.004DFD33-86256D2F.005647E2@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Fri, 23 May 2003 10:42:25 -0500
   
   I'll try and do some debugging and see if I can find the problem.

Thanks.  It is possible that I broke something while transferring
the flow cache into a generic location... but you did not see these
hangs with plain 2.5.69 which had that change already.

I'll be away for the weekend, so don't be alarmed if I am silent
during this time :-)
