From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 0/3] [bonding 2.6] Using per-bond parameters
Date: Mon, 5 Jan 2004 17:29:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051729.45524.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following patch set makes each bonding interface keep its own set 
of parameters, rather than use global values.

This is the first step necessary to allow the configuration of 
different parameters to different bonding interfaces.

The patches are against the net-drivers-2.5-exp tree (after Shmulik's 
'update comment blocks' patch).

-- 
Amir
