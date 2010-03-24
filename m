From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 00/07] net: remove trailing spaces in messages
Date: Wed, 24 Mar 2010 19:27:09 +0100
Message-ID: <201003241927.12434.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Corey Thomas <coreythomas@charter.net>,
	libertas-dev@lists.infradead.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the third patchset to remove trailing spaces in kernel messages. 
Patches in this set cover wireless code.

Note that the last patch for libertas changes a debugfs header and not 
actually a message.

Patches have been rebased against current net-next.

Benefits are:
- general cleanup and consistency
- minor reduction in kernel size and user's log file size
- reduced annoyance for people writing logcheck rules

Shortstat:
 30 files changed, 124 insertions(+), 124 deletions(-)

Frans Pop (7):
      wireless: remove trailing space in messages
      wireless/ath: remove trailing space in messages
      wireless/ipw2x00: remove trailing space in messages
      wireless/iwlwifi: remove trailing space in messages
      wireless/prism54: remove trailing space in messages
      wireless/raylink: remove trailing space in messages
      wireless/libertas: remove trailing space in debugfs header

Cheers,
FJP
