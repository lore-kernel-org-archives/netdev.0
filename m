From: Shmuel Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH-2.4] add missing '\n' in bonding messages
Date: Wed, 28 Jan 2004 15:23:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401281523.00369.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A03A9CCD3@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="tscii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Willy Tarreau" <willy@w.ods.org>, <marcelo.tosatti@cyclades.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A03A9CCD3@hasmsx403.iil.intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 28 January 2004 15:04, Willy Tarreau wrote:
>
> there are a few places where the bonding driver displays
> informational messages without the trailing '\n', which is
> sometimes annoying because messages get logged at the wrong level.
>
> Here's the patch against 2.4.25-pre7. I haven't checked 2.6 nor the
> bonding cleanup patch against those typos.
>

All those fixes are in the cleanup set and have been picked up by Jeff 
for both netdev-2.4 and netdev-2.6 BK trees. To the best of my 
understanding, they will be held until 2.4.25 and 2.6.2 are released.


-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
