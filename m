From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 0/5 2.5] e1000: driver update
Date: Fri, 15 Oct 2004 06:52:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150537500.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1. modified ethtool_set_pauseparam to use e1000_setup_link for flow control
settings for fiber serdes link
2. remove unused function e1000_enable_mng_pass_thru
3. fix set ringparam for ethtool returning error code on bad input
4. driver version number update
5. white space corrections
