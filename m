From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] Add capability to retrieve plug-in module
 EEPROM
Date: Mon, 23 Apr 2012 17:28:48 -0400 (EDT)
Message-ID: <20120423.172848.1733968863825393980.davem@davemloft.net>
References: <4F9031BF.10106@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	bruce.w.allan@intel.com, decot@google.com,
	alexander.h.duyck@intel.com, linux-kernel@vger.kernel.org
To: smhodgson@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9031BF.10106@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You can't just submit three seperate patches each with the same exact
Subject line.

Otherwise someone scanning the commit headers can't figure out what
is different in each of these changes.

There also is no signoff from Ben for patches #2 or #3, did he review
them?  If so, why didn't he ACK or sign off on it?  If not, why not?
