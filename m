From: James Morris <jmorris@intercode.com.au>
Subject: (no subject)
Date: Mon, 30 Jun 2003 09:00:49 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306300859240.22482-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please pull from bk://kernel.bkbits.net/jmorris/net-2.5 for the followng 
changesets:

ChangeSet@1.1525.1.1, 2003-06-29 20:37:48+10:00, yoshfuji@linux-ipv6.org
  [IPV6] Don't set M flag in last fragment.

ChangeSet@1.1525.1.2, 2003-06-29 20:38:55+10:00, yoshfuji@linux-ipv6.org
  [IPV6] Use macro for M-Flag and clean-up.

ChangeSet@1.1525.1.3, 2003-06-29 20:40:01+10:00, yoshfuji@linux-ipv6.org
  [IPV6] Convert /proc/net/ip6_flowlabel to seq_file.

ChangeSet@1.1528, 2003-06-30 01:53:54+10:00, yoshfuji@linux-ipv6.org
  [XFRM] Fix typo.

ChangeSet@1.1529, 2003-06-30 02:17:41+10:00, herbert@gondor.apana.org.au
  [XFRM] Set SA saddr correctly
  
ChangeSet@1.1525.2.1, 2003-06-30 02:28:59+10:00, herbert@gondor.apana.org.au
  [IPSEC] split xfrm_state_replace + fixes



- James
-- 
James Morris
<jmorris@intercode.com.au>
