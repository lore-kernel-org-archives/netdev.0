From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 0/17 linux-2.6.7-rc2] prism54: Bring prism54 up to sync
Date: Sun, 30 May 2004 22:07:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040530211258.00ae3b70@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patches to linux-2.6.7-rc2.
These patches bring the kernel tree up to sync with prism54.org's 1.2 release.

[PATCH 1/17 linux-2.6.7-rc1] prism54: delete cvs tags
[PATCH 2/17 linux-2.6.7-rc1] prism54: add new private ioctls
[PATCH 3/17 linux-2.6.7-rc1] prism54: reset card on tx_timeout
[PATCH 4/17 linux-2.6.7-rc1] prism54: add iwspy support
[PATCH 5/17 linux-2.6.7-rc1] prism54: add support for avs header in monitor 
mode
[PATCH 6/17 linux-2.6.7-rc1] prism54: new prism54 kernel compatibility
[PATCH 7/17 linux-2.6.7-rc1] prism54: Fix endian bug
[PATCH 8/17 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 74, 75
[PATCH 9/17 linux-2.6.7-rc1] prism54: Fix prism54.org bugs 39, 73
[PATCH 10/17 linux-2.6.7-rc1] prism54: Fix prism54.org bug 77; strengthened 
oid transaction
[PATCH 11/17 linux-2.6.7-rc1] prism54: Don't allow mib reads while unconfigured
[PATCH 12/17 linux-2.6.7-rc1] prism54: Start using likely/unlikely
[PATCH 13/17 linux-2.6.7-rc1] prism54: Align skb data
[PATCH 14/17 linux-2.6.7-rc1] prism54: Reduce verbosity
[PATCH 15/17 linux-2.6.7-rc1] prism54: Fix channel stats; bump to 1.2
[PATCH 16/17 linux-2.6.7-rc1] prism54: Simplify firmware load call
[PATCH 17/17 linux-2.6.7-rc1] prism54: White space and indent

Margit
