From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Missing IPv6 policy checks
Date: Sat, 29 Mar 2003 04:06:05 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030329.040605.83500303.davem@redhat.com>
References: <1048864940.14454.10.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1048864940.14454.10.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 28 Mar 2003 09:22:15 -0600
   
   Please review and let me know if I should make any changes.

Applied, thanks.

SCTP was missing no_policy=1 for both ipv4/ipv6 and I took
care of that at the same time.
