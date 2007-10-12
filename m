From: Al Boldi <a1426z@gawab.com> (by way of Al Boldi <a1426z@gawab.com>)
Subject: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 08:14:23 +0300
Message-ID: <200710120814.23903.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the existence of the mangle table, how useful is the filter table?

Other than requiring the REJECT target to be ported to the mangle table, is
the filter table faster than the mangle table?

If not, then shouldn't the filter table be obsoleted to avoid confusion?


Thanks!

--
Al

