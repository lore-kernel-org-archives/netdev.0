From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc4 0/3] sk98lin: neuter and prepare for removal
Date: Tue, 18 Oct 2005 21:30:59 -0400
Message-ID: <10182005213059.12304@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, mlindner@syskonnect.de,
	rroesler@syskonnect.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751520AbVJSBcX@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches take steps towards removing sk98lin from the upstream
kernel.

	-- Remove sk98lin's MODULE_DEVICE_TABLE to avoid
	confusing userland tools about which driver to load;

	-- Mark sk98lin as Obsolete in the MAINTAINERS file; and,

	-- Add sk98lin to the feature-removal-schedule.txt file in the
	Documentation directory.

I accept the possibility that I may be jumping the gun on this.
However, I think it is worth opening this discussion.

Patches to follow...
