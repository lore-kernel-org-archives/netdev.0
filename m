From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: 3 linux-next based backports releases
Date: Thu, 17 Apr 2014 18:52:44 -0700
Message-ID: <CAB=NE6WD0AB4qk7t=bszdv61F2g2NvDei_tcx2o98=kQvUuh-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-media@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-zigbee-devel@lists.sourceforge.net
To: "backports@vger.kernel.org" <backports@vger.kernel.org>
Return-path: <linux-media-owner@vger.kernel.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3 new linux backports release are now available based on linux-next
tags next-20140320 [0] next-20140411 [1] and next-20140417 [2]. This
should mean that we can keep things in synch now almost daily, and
drivers can be tested with the latest code as-is on linux-next. We've
shaved off kernel support for kernels older than 3.0 in order to help
scale the project. We've also have added 2 new SmPL patches to help
backports backport two pain in the ass collateral evolutions
automatically. Please note that the patches/ directory is now all
tidied up -- folks interested in playing with SmPL can try to help by
seeing if they can use SmPL grammer to formalize a collateral
evolution backport. We have a bit of examples now. For more details
please refer to the wiki [3] or git tree.

[0] http://www.kernel.org/pub/linux/kernel/projects/backports/2014/03/20/backports-20140320.tar.xz
[1] https://www.kernel.org/pub/linux/kernel/projects/backports/2014/04/11/backports-20140411.tar.xz
[2] https://www.kernel.org/pub/linux/kernel/projects/backports/2014/04/17/backports-20140417.tar.xz
[3] http://backports.wiki.kernel.org

  Luis
