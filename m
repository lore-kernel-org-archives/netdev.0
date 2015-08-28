From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Some phylib simplifications
Date: Fri, 28 Aug 2015 21:33:43 +0300
Message-ID: <2163825.63u61975nF@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's 2 patches against DaveM's 'net-next.git' repo. We simplify a bogus
string of type casts in the 1st patch and make the code respect some coding
standards of the networking code in the 2nd one. I may follow with fixing of
checkpatch.pl's complaints. if I have time..

[1/2] phylib: simplify bogus phy_device_create() result
[2/2] phylib: simplify NULL checks

MBR, Sergei
