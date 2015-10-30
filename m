From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 0/2] sh_eth: fix bugs in sh_eth_ring_init()
Date: Sat, 31 Oct 2015 02:05:19 +0300
Message-ID: <3291270.dPgp9opalf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo which fix couple of
bugs in the sh_eth_ring_init() function.

[1/2] sh_eth: fix uninitialized arrays in sh_eth_ring_init()
[2/2] sh_eth: fix WARNING in dma_common_free_remap()

MBR, Sergei

