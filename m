From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [softmac-dev] [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx or ieee80211_rx_mgt
Date: Mon, 23 Jan 2006 20:00:11 +0100
Message-ID: <200601232000.12400.stefan@loplof.de>
References: <20060118200616.GC6583@tuxdriver.com> <200601221404.52757.vda@ilport.com.ua> <1138026752.3957.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	"John W. Linville" <linville@tuxdriver.com>, jbenc@suse.cz,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964899AbWAWTBR@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1138026752.3957.98.camel@localhost>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag 23 Januar 2006 15:32 schrieb Johannes Berg:

> Shouldn't you BSS-filter management packets too?

no, management packets are used to populate f.e. scanning results.

Stefan
