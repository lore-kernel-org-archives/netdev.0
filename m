From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] conntrack-tools 1.2.2 release
Date: Tue, 31 Jul 2012 13:22:32 +0200
Message-ID: <20120731112232.GA3294@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        conntrack-tools 1.2.2

This release contains accumulated bugfixes.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/conntrack-tools/downloads.html
ftp://ftp.netfilter.org/pub/conntrack-tools/

Have fun!

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-conntrack-tools-1.2.2.txt"

Jan Engelhardt (1):
      update .gitignore

Pablo Neira Ayuso (7):
      conntrackd: simplify TCP connection handling logic
      conntrackd: fix compilation in src/parse.c
      doc: fix documentation on ExpectationSync and H.323 helper
      conntrackd: add bugtrap notice in case of flush while commit in progress
      conntrackd: fix commit operation, needs to be synchronous
      conntrackd: implement selective flushing for `-t' and `-F' commands
      bump version to 1.2.2


--bg08WKrSYDhXBjb5--
