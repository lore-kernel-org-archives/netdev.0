From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug in ipv6 ipsec in handling of packets with extension headers
Date: Thu, 05 Jun 2003 05:17:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.051709.104035049.davem@redhat.com>
References: <3EDF36AA.9020403@tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lpetande@tml.hut.fi
In-Reply-To: <3EDF36AA.9020403@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Henrik Petander <lpetande@tml.hut.fi>
   Date: Thu, 05 Jun 2003 15:25:14 +0300
   
   A possible fix is to change the pointer into an offset from the start of 
   the packet and use the offset later to set the nexthdr value in the 
   extension header.

Please indicate the version of the sources you are looking
at when making reports.

Thank you.
