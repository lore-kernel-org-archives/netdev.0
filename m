From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: fix couple of bugs in sh_eth_ring_format()
Date: Tue, 08 Mar 2016 01:33:38 +0300
Message-ID: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo fixing two bugs
in sh_eth_.ring_format()...

[1/2] sh_eth: fix NULL pointer dereference in sh_eth_ring_format()
[2/2] sh_eth: advance 'rxdesc' later in sh_eth_ring_format()

MBR, Sergei
