From: Shirley Ma <xma@us.ibm.com>
Subject: ifindex & iflink in net_device
Date: Wed, 17 Sep 2003 15:16:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4BF13F5B.51B69DCE-ON87256DA4.007925AC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





In structure net_device, ifindex is defined as interface index, iflink is
defined as unique device indentifier. I've checked the iflink assignments,
it's equal to ifindex in most cases, pretty confused. For IPv6, I read the
RFC2373. I wonder iflink might be EUI-64 in section 2.5.1 Interface
Identifiers? Anyone knows about the iflink?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
