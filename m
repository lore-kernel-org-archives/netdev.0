From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: "intgelligent checksum" related cleanups
Date: Sat, 07 Jan 2017 00:01:40 +0300
Message-ID: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo, as they are based
on a couple patches merged there recently; however, the patches are destined
for 'net-next.git' (once 'net.git' gets merged there next time). I'm cleaning
up the "intelligent checksum" related code (however, the driver only disables
this feature for now, theres's no proper offload supprt yet).

[1/2] sh_eth: get rid of 'sh_eth_cpu_data::shift_rd0'
[2/2] sh_eth: rename 'sh_eth_cpu_data::hw_crc'

MBR, Sergei
