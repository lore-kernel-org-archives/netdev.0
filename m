From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.4.1 release
Date: Sun, 3 Mar 2013 23:10:35 +0100
Message-ID: <20130303221035.GB28022@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SkvwRMAIpAhPCcCJ"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.4.1

The conntrack-tools are the userspace command line interface
`conntrack' and the userspace daemon `conntrackd'. The conntrack
utility replaces the old /proc/net/nf_conntrack interface. With
conntrack, you can dump, modify and delete entries from the connection
tracking state table from userspace. On the other hand, conntrackd
allows you to deploy highly available stateful firewall clusters and
to run connection tracking helpers from user-space.

More information in the official manual at:
http://conntrack-tools.netfilter.org/manual.html

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/nfacct/downloads.html
ftp://ftp.netfilter.org/pub/nfacct/

Have fun!


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.4.1.txt"

Pablo Neira Ayuso (3):
      conntrackd: fix deadlock due to wrong nested signal blocking
      conntrack: add support to dump the dying and unconfirmed list via ctnetlink
      build: bump version to 1.4.1


--SkvwRMAIpAhPCcCJ--
