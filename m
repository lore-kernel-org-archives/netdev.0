From: David Miller <davem@davemloft.net>
Subject: Re: XTP for 2.6.25
Date: Thu, 24 Apr 2008 03:30:29 -0700 (PDT)
Message-ID: <20080424.033029.193698693.davem@davemloft.net>
References: <18b669d80804240314t7b2f6e4cpc9a9f2690c6d21b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shigeonx@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754778AbYDXKan@vger.kernel.org>
In-Reply-To: <18b669d80804240314t7b2f6e4cpc9a9f2690c6d21b4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shigeo N" <shigeonx@gmail.com>
Date: Thu, 24 Apr 2008 19:14:38 +0900

[ netdev added to CC: ]

> I implemented Xpress Transport Protocol 4.0 for Linux kernel 2.6.25.
> Does anyone test it and give me feedback to enhance together ?
> 
> I tested in the network where UDP throughput is 29Mbps, then TCP
> throughput was 13Mbps, but XTP's reached to 25Mbps.
> 
> The source is here.
> <http://downloads.sourceforge.net/linux-xtp/linux-xtp.0.3.1.tar.gz?use_mirror=osdn>
> 
> XTP specification is here.
> <http://www.packeteer.com/resources/prod-sol/XTP.pdf>
> 
> Multicast function is not implemented yet.

Please discuss your work on netdev@vger.kernel.org, which is where
the Linux networking developers are listening.

Thank you.
