From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Kill useless *switch* defaults in the Renesas Ethernet drivers
Date: Sun, 14 Feb 2016 22:55:05 +0300
Message-ID: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net-next.git' repo removing
often used *default* cases doing nothing.

[1/2] ravb: kill useless *switch* defaults
[2/2] sh_eth: kill useless *switch* defaults

MBR, Sergei
