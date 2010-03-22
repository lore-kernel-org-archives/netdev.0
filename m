From: "Justin P. mattock" <justinmattock@gmail.com>
Subject: forcedeth: cat /sys/class/net/eth0/carrier = Invalid argument
Date: Mon, 22 Mar 2010 10:36:18 -0700
Message-ID: <4BA7AA92.5040400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've pushed my kernel from the latest HEAD to 2.6.31
and am still seeing:
cat /sys/class/net/eth0/carrier
cat: carrier: Invalid argument

with my other machine using sky2
the same results is:
cat /sys/class/net/eth0/carrier
0

is there anything on this? before I start
a bisect.(looking through bugzilla, I couldn't
see anything related).

Justin P. Mattock
