From: Vinod <geekvinod@yahoo.com>
Subject: making routes permanent
Date: Sun, 28 Apr 2002 10:55:22 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020428175522.12005.qmail@web21102.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

how can one make route's permanent?
i wanted to make this permanent:
route add -net 10.0.3.0 netmaks 255.255.255.0 gw
10.0.0.10 dev eth1

i tried putting this in /etc/sysconfig/static-routes
but it didnt work.
i have rh7.2 installed.
Thanks in advance,
Vinod


__________________________________________________
Do You Yahoo!?
Yahoo! Health - your guide to health and wellness
http://health.yahoo.com
