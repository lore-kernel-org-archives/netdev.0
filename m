From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 0/7] isdn: eicon: Silence frame size warnings
Date: Fri,  8 Jan 2016 05:32:48 -0700
Message-ID: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following is a patch set to recode various functions within the eicon driver in
order to silence frame size warnings. The final patch consolidates some of this
code into a single function which hopefully reduces complexity and the amount
of code.

-- 
Tim Gardner tim.gardner@canonical.com
