From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.17 release
Date: Tue, 25 Dec 2012 14:09:07 +0100
Message-ID: <20121225130907.GA27528@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        iptables 1.4.17

More relevantly, this release includes the IPv6 NAT extensions from
Patrick McHardy, the ignore day transition from Florian Westphal and
a couple of fixes.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/

Have fun!

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-iptables-1.4.17.txt"

Florian Westphal (1):
      libxt_time: add support to ignore day transition

Jozsef Kadlecsik (1):
      Manpage update: matches are evaluated in the order they are specified.

Pablo Neira Ayuso (2):
      Merge branch 'next' branch that contains new features scheduled for     Linux kernel 3.7
      bump version to 1.4.17

Patrick McHardy (7):
      Convert the NAT targets to use the kernel supplied nf_nat.h header
      extensions: add IPv6 MASQUERADE extension
      extensions: add IPv6 SNAT extension
      extensions: add IPv6 DNAT target
      extensions: add IPv6 REDIRECT extension
      extensions: add IPv6 NETMAP extension
      extensions: add NPT extension

Tom Eastep (1):
      extensions: libxt_statistic: Fix save output


--YZ5djTAD1cGYuMQK--
