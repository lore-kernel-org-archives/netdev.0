From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] Update in-kernel orinoco drivers to upstream current CVS
Date: Fri, 02 Jul 2004 15:11:38 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1088795498.18039.25.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264843AbUGBTLo@vger.kernel.org>
To: linux-kernel@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch is simply the fixed-up diff between the kernel's current
0.13e version and the upstream 0.15rc1+ version from savannah CVS.
0.15rc1 has been out for a couple months now and seems stable.

The major benefits that this newer version brings are, of course, many
bugfixes, but best of all wireless scanning support for the Orinoco line
of cards.

http://people.redhat.com/dcbw/linux-2.6.7-orinoco.patch.bz2

Dan Williams
Red Hat, Inc.
