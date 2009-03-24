From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v2.6.29
Date: Tue, 24 Mar 2009 15:34:27 -0700
Message-ID: <20090324153427.3ff0dfdb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trying to stay on top of things (for a change).

New version of iproute2 utilities that includes bug fixes and
support for all the new features in kernel 2.6.29.

  http://devresources.linux-foundation.org/dev/iproute2/download/iproute2-2.6.29.tar.bz2

Denys Fedoryschenko (1):
      Fix memory leak in local options

Jamal Hadi Salim (1):
      Breakage noticed when debian upgraded to xtables (iptables > 1.4.1)

Patrick McHardy (1):
      iproute: add DRR support

Stephen Hemminger (7):
      fix uninitialized memory in tc_skbedit
      Add missing limits.h
      Add DHCP as routing protocol
      Add support for IFALIAS
      Handle default hoplimit
      Use sanatized headers from 2.6.29
      Update snapshot
