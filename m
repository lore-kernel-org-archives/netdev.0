From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] New Patch: Implementation for IPv6 MIB:ipv6AddressTable
Date: Fri, 10 Oct 2003 14:42:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF76B6670E.FBF6325A-ON87256DBB.0061E032@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





> Why are you using jiffies for timestamps?  I guess these values
are measured "since bootup" or something like that?

Yes. The timestamp is the value of sysUpTime at the time this entry was
created.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
