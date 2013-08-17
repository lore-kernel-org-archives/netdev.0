From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] SH: fix platform Ether support
Date: Sun, 18 Aug 2013 02:13:22 +0400
Message-ID: <201308180213.23296.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   [Resending with correct David's email.]

   Here's a couple of patches fixing Ether support on some SH platforms.
They are against David Miller's 'net.git' (and also apply to 'net-next.git)
since they are prerequisite for the 'sh_eth' driver cleanup patchset that will
be posted a bit later. David, can I ask you to push these patches thru your
tree for that reason?

[1/2] SH7619: fix Ether support
[2/2] SolutionEngine7724: fix Ether support

WBR, Sergei
