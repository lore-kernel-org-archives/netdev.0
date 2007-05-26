From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.22 0/7] cxgb3 - bug fixes
Date: Sat, 26 May 2007 15:59:12 -0700
Message-ID: <4658BBC0.3050907@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753936AbXEZW7g@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.22.
The patches are built against Linus'git tree.

Here is a brief description:
- Fix page management in the SGE code,
- Fix netpoll handler,
- Fix link status detection for direct XAUI adapters,
- Update FW to 4.1 and proceed to subsequent HW tuning,
- Work around potential hang on MTU change,
- Fix MAC watchdog,
- Allow microcode update without a power cycle.

Cheers,
Divy
