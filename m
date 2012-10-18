From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.16.3 release
Date: Thu, 18 Oct 2012 11:26:48 +0200
Message-ID: <20121018092648.GA18893@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.16.3

This release fixes the static builds and compile on RHEL5.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.16.3.txt"

Jan Engelhardt (2):
      build: remove symlink-only extensions from static object list
      build: resolve compile abort in libxt_limit on RHEL5

Pablo Neira Ayuso (1):
      bump iptables to 1.4.16.3


--gBBFr7Ir9EOA20Yy--
