From: Jeff Garzik <jgarzik@pobox.com>
Subject: ethtool version 2 released
Date: Tue, 17 Aug 2004 08:26:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4121F991.4000004@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just released a small update to ethtool, version 2, posted at

	http://sourceforge.net/projects/gkernel/

Like its cousin "blktool", ethtool now has a simplified version scheme, 
an ascending number.

For those unfamiliar with ethtool, it is a utility designed to configure 
specific features founds on most ethernet cards.

Summary of changes (mainly the new version scheme):

         * Feature: ethtool register dump raw mode
         * Feature: return results of self-test back to OS via exit(2)
         * Feature: add verbose register dump for pcnet32, fec_8xx
         * Maintenance: update to more recent autoconf
         * Maintenance: minor updates to e1000-specific module
         * Bug fix: Remove silly restriction on ethernet interface naming
