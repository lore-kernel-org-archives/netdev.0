From: ganesh.venkatesan@intel.com
Subject: [PATCH 0/6 2.5] e100 driver update
Date: Thu, 29 Jul 2004 08:26:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290612510.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff:

Following is a list of patches against the 2.6 tot for e100:

1 -- fix diagnostic test to restore current speed/duplex/autoneg settings 
after the completion of the diagnostic tests
2 -- Support for Intel(R) PRO/100 VE Network Connection (82562) adapter
3 -- fix errors in counting rx_length_errors and rx_over_errors
4 -- support for loading device firmware
5 -- Auto MDI/MDI-X Support
6 -- driver version change

thanks,
ganesh.
