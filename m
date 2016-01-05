From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v4.2.y-ckt] net/mlx5e: Max mtu comparison fix
Date: Tue, 5 Jan 2016 16:01:04 -0500
Message-ID: <568C2F10.9040707@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: doront@mellanox.com, saeedm@mellanox.com, ogerlitz@mellanox.com,
	"davem@davemloft.net" <davem@davemloft.net>, eli@mellanox.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Kamal Mostafa <kamal.mostafa@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please consider including mainline commit
50a9eea694ab8e0779069e0a4e0b12e145521468 in the next v4.2.y-ckt
release.  It was
included in the mainline tree as of v4.4-rc2.  It has been tested and
confirmed to resolve:
http://bugs.launchpad.net/bugs/1528466

commit 50a9eea694ab8e0779069e0a4e0b12e145521468
Author: Doron Tsur <doront@mellanox.com>
Date:   Thu Nov 12 19:35:27 2015 +0200

    net/mlx5e: Max mtu comparison fix


Sincerely,

Joseph Salisbury
