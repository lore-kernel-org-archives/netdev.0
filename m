From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH 3/3] rx_all e100 patch
Date: Tue, 25 Nov 2003 09:39:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCF8@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben, I'd rather not touch e100-2.3.x as it's going to be replaced soon
with e100-3.0.x.  Can you switch over to e100-3.0.x for this
development?  It's up on the sf.net/projects/e1000 web site.  I think
you'll find this patch collapses into much fewer lines with the new
driver.  It has ethtool_ops support also.  I can work on the e100-3.0.x
patch if you don't want to redo the work.  Let me know.

-scott
