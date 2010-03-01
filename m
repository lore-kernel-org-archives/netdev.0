From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of iptables-1.4.7
Date: Mon, 01 Mar 2010 16:20:50 +0100
Message-ID: <4B8BDB52.1020802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000308090800050003090502"
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000308090800050003090502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The netfilter coreteam presents:

    iptables version 1.4.7

the iptables release for the 2.6.33 kernel. Changes include:

- libipq is built as a shared library
- removal of some restrictions on interface names
- documentation updates
- code cleanups

See the changelog for more details.

Version 1.4.7 can be obtained from:

http://www.netfilter.org/projects/iptables/downloads.html
ftp://ftp.netfilter.org/pub/iptables/
git://git.netfilter.org/iptables.git

On behalf of the Netfilter Core Team.
Happy firewalling!


--------------000308090800050003090502
Content-Type: text/plain;
 name="changes-iptables-1.4.7.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="changes-iptables-1.4.7.txt"

Dmitry V. Levin (1):
      libip4tc: Add static qualifier to dump_entry()

Jan Engelhardt (8):
      libipq: build as shared library
      recent: reorder cases in code (cosmetic cleanup)
      doc: fix recent manpage to reflect actual supported syntax
      doc: fix limit manpage to reflect actual supported syntax
      doc: mention requirement of additional packages for ipset
      policy: fix error message showing wrong option
      includes: header updates
      Lift restrictions on interface names

Patrick McHardy (1):
      iptables 1.4.7


--------------000308090800050003090502--
