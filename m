From: Jeff Garzik <jgarzik@pobox.com>
Subject: Regarding SET_NETDEV_DEV
Date: Tue, 3 Jun 2003 13:59:21 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030603175921.GE2079@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

For janitors and other developers placing this in net drivers...
please don't :)  This can be done in upper layers, accomplishing the
same goal without changing the low-level net driver code at all.

	Jeff




