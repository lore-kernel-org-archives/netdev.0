From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: non-NAPI mode question netif_rx_schedule()
Date: Thu, 15 Apr 2004 11:07:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF6008@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jens Laas" <jens.laas@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> __LINK_STATE_RX_SCHED is set on queue->backlog_dev not on the "real"
> netdev.
> 
> The backlog_dev is per queue and thus per CPU.

Ah, thanks!
