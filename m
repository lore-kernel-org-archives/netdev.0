From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 08:29:23 -0800
Message-ID: <1260894563.4041.31.camel@localhost.localdomain>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760584AbZLOQ3o@vger.kernel.org>
In-Reply-To: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

> We've experienced a long standing bug when quickly switching from
> ad-hoc to managed mode on a hardware using a Libertas chipset.

I don't know where you get your list of mailing lists from, but not
sending it to linux-wireless@vger.kernel.org will not really get you
anywhere. Check MAINTAINERS file first since it has all information
about it.

NETWORKING [WIRELESS]
M:      "John W. Linville" <linville@tuxdriver.com>
L:      linux-wireless@vger.kernel.org
T:      git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
S:      Maintained
F:      net/mac80211/
F:      net/rfkill/
F:      net/wireless/
F:      include/net/ieee80211*
F:      include/linux/wireless.h
F:      drivers/net/wireless/

Regards

Marcel
