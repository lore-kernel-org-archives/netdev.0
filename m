From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: nfs broken in net-next?
Date: Wed, 28 Oct 2009 13:13:56 -0700
Message-ID: <86802c440910281313h2ca89c94w99121edffbf6ce53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755003AbZJ1UNx@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
mount.nfs: rpc.statd is not running but is required for remote locking.
mount.nfs: Either use '-o nolock' to keep locks local, or start statd.


using opensuse11.1

YH
