From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc2 0/10] add bcm5752 support plus some cleanup to tg3
Date: Wed, 13 Apr 2005 19:38:43 -0400
Message-ID: <04132005193843.8300@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add support to tg3 for bcm5752 hardware.  Also clean-up a lot
of multi-way if statements and replace them with checks of flags
representing classes of tg3 hardware.

Patches to follow...
