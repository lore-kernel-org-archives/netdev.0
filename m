From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: e100 "Twin City" release
Date: Mon, 23 Jun 2003 15:46:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D9DD@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks to Jason, Udo, Zose, and David for the feedback so far.  New
version posted: http://sf.net/projects/e1000, download e100-3.0.0_dev9.

Changes from e100-3.0.0-dev8:

* Added Device ID 0x1029.
* Named union for compilers not supporting anonymous unions.
* Initialize struct for ETHTOOL_GRINGPARAM.

DON'T USE THIS DRIVER ON A PRODUCTION SYSTEM!

-scott
