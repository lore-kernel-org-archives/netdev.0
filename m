From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Wed, 8 Oct 2003 11:55:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4B7AD7E2.5CA239A1-ON87256DB9.0067C527@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





I think it's better to define MAX_JIFFIES unsigned long.

#define MAX_JIFFIES (~0UL)

Should I resent the whole patch again?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
