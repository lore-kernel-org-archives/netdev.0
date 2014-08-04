From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 3.16.0 release
Date: Mon, 4 Aug 2014 12:56:49 -0700
Message-ID: <20140804125649.49fcbf92@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Time for the release of iproute2 for 3.16.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.16.0.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing list.

---

Daniel Borkmann (1):
      man: token: fix couple of typos

Dmitry Popov (1):
      fix ip tunnel for vti tunnels with ikey

Jamal Hadi Salim (1):
      iproute2 bridge: bring to above par with brctl show macs

Jay Vosburgh (1):
      tc/netem: loss gemodel options fixes

Masatake YAMATO (1):
      ip: add nlmon as a device type to help message

Rami Rosen (1):
      iplink: macvtap: fix man page

Roopa Prabhu (2):
      bridge: Add master device name to bridge fdb show
      link dump filter

Stephen Hemminger (7):
      Update to current net-next kernel headers
      Merge branch 'net-next'
      Update kernel headers to 3.16-rc5
      ip: add paren to silence warning
      ip: check for missing dev arg when doing VF rate
      cleanup warnings
      v3.16.0

Sucheta Chakraborty (1):
      Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool

Vasily Averin (1):
      ipnetns: fixed typo "seting" -> "setTing"

vadimk (1):
      ip: Added missing usage for netconf object
