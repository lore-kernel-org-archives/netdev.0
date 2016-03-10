From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Thu, 10 Mar 2016 13:58:24 +0100
Message-ID: <1457614704.2478.11.camel@tiscali.nl>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
	 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
	 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
	 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
	 <1457340486.2737.19.camel@tiscali.nl> <56E09F4A.8010202@imap.cc>
	 <56E15211.7080206@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, Arnd Bergmann <arnd@arndb.de>,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	linux-arm-kernel@lists.infradead.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: isdn@linux-pingi.de
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <56E15211.7080206@linux-pingi.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Karsten,

On do, 2016-03-10 at 11:53 +0100, isdn@linux-pingi.de wrote:
> mISDN with CAPI support works just fine with pppd and pppdcapiplugin
> and the CAPI works for all mISDN HW.

In the mainline tree the mISDN and CAPI stacks are effectively separate.
Do you perhaps refer to a mISDN + Asterisk + chan-capi setup? (That's
the closest to mISDN with CAPI support that I could find. Did I miss
something?)

Thanks,


Paul Bolle
