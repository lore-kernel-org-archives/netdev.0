From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 0/5 2.4] e1000 driver update
Date: Fri, 17 Sep 2004 02:55:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170213160.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1) Removed support for advanced TCO features
2) Fix MODULE_PARM, module_param and module_param_array 
3) Fix VLAN filter setup errors (while running on PPC)
4) Polarity reversal workaround for 10F/10H links
5) White space changes, driver version number update and others
