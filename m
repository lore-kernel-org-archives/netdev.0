From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [INTRO] r8169 patches + call for vict^W testers
Date: Thu, 20 May 2004 14:35:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520143500.A28948@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some code has been added to the latest r8169 patches to make the proud
users of TBI on r8169 happy. The patches are labelled as 2.6.6-mm4
to work with the script you use for importing patches but they are actually
against 2.6.6 + bk-netdev. If it is ok to merge the patches, one should
tell M.Morton that he can simple drop the patches below (the names are
related to its own tree) :
- 266-mm2-r8169-ethtool-get_settings.patch
- 266-mm2-r8169-ethtool-set_settings.patch
- 266-mm2-r8169-link-handling-rework-1-2.patch
- 266-mm2-r8169-link-handling-rework-2-2.patch

I do not have a r8169 with a fiber interface and it is not even on the weekly
purchase list. Adequate testers will be welcome.

If the patches look sane, I'll generate the usual all-in-one patches (2.4 and
2.6) for the impatient testers.

--
Ueimor
