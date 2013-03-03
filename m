From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.18 release
Date: Sun, 3 Mar 2013 23:20:08 +0100
Message-ID: <20130303222008.GA28215@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.18

iptables is the userspace command line program used to configure the
Linux 2.4.x and later packet filtering ruleset. It is targeted towards
system administrators.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.18.txt"

Florian Westphal (1):
      doc: rpfilter: invert option should have own paragraph

Jan Engelhardt (11):
      build: resolve link failure for ip6t_NETMAP
      doc: fixup omissions in ip6tables-restore.8
      doc: document iptables-restore's -t option
      doc: document iptables-restore's -v option
      doc: document iptables-restore's -M option
      doc: document iptables-restore's -h option
      doc: name the supported log levels for ipt_LOG
      doc: mention -m in the manpage
      doc: document the -4 and -6 options
      extensions: S/DNPT: add missing save function
      build: bump SONAME for libxtables

Jozsef Kadlecsik (3):
      Introduce match/target aliases
      Add the "state" alias to the "conntrack" match
      Merge branch 'master' of vishnu.netfilter.org:/data/git/iptables

Pablo Neira Ayuso (7):
      iptables: remove unused leftover definitions
      libxtables: add xtables_rule_matches_free
      libxtables: add xtables_print_num
      Merge branch 'stable' into 'master'
      doc: document nat table for IPv6
      doc: iptables provides up to 5 independent tables
      build: bump version to 1.4.18

Ulrich Weber (3):
      extensions: libip6t_DNPT: fix wording in DNPT target
      extension: libip6t_DNAT: allow port DNAT without address
      extensions: libip6t_DNAT: set IPv6 DNAT --to-destination


--T4sUOijqQbZv57TR--
