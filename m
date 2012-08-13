From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 3.5.1
Date: Mon, 13 Aug 2012 08:25:15 -0700
Message-ID: <20120813082515.1582bfbb@nehalam.linuxnetplumber.net>
References: <20120801160550.344a66b1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120801160550.344a66b1@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm re-releasing the iproute2 tools for 3.5.0 kernel.

There were a couple of bugs (one serious) in the 3.5.0 version.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.5.1.tar.gz

The iproute2 3.5.1 git tree can be found at:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git iproute-3.5.1


-----------

Mike Frysinger (1):
      Fix regression with 'ip address show'

Stephen Hemminger (1):
      v3.5.1

Xose Vazquez Perez (1):
      Fix Makefile's
