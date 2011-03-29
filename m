From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] bridge-utils 1.5
Date: Mon, 28 Mar 2011 18:13:06 -0700
Message-ID: <20110328181306.2b1a117e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, bridge@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Bridge Utilities haven't been re-released in a very long time.
The only new feature is the introduction of hairpin mode.

Note: this is probably the last release of these utilities because
I am actively working on intergrating bridge utility into iproute2
using netlink.

Package download:
   http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz/download

Repository:
   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/bridge-utils.git

Information:
   http://www.linuxfoundation.org/collaborate/workgroups/networking/bridge

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

Changelog:

Anton Danilov (1):
      show selected bridge

Fischer, Anna (1):
      bridge-utils: Add 'hairpin' port forwarding mode

Stephen Hemminger (8):
      don't install libbridge.a
      use proper version of install in doc/Makefile
      Check for fopen() failing
      Skip . and .. in foreach_bridge test
      Handle unknown attributes more gracefully
      bridge-utils 1.5
      update mailing address
      Update URL of git repository
