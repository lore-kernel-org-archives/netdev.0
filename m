From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Sun, 1 Aug 2010 21:14:29 +0200
Message-ID: <20100801191429.GA12432@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de> <8DD2590731AB5D4C9DBF71A877482A9001623EC48E@orsmsx509.amr.corp.intel.com> <20100730125614.GB21444@torres.zugschlus.de> <8DD2590731AB5D4C9DBF71A877482A9001649C4653@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001649C4653@orsmsx509.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2010 at 10:42:03AM -0700, Allan, Bruce W wrote:
> Please also provide an eeprom dump from the wired LOM via 'ethtool -e ethX'.

Offset          Values
------          ------
0x0000          00 16 41 aa be 37 30 0b b2 ff 51 00 ff ff ff ff
0x0010          53 00 03 01 6b 02 01 20 aa 17 9a 10 86 80 df 80
0x0020          00 00 00 20 54 7e 00 00 14 00 da 00 04 00 00 27
0x0030          c9 6c 50 31 3e 07 0b 04 8b 29 00 00 00 f0 02 0f
0x0040          08 10 00 00 04 0f ff 7f 01 4d ff ff ff ff ff ff
0x0050          14 00 1d 00 14 00 1d 00 af aa 1e 00 00 00 1d 00
0x0060          00 01 00 40 1f 12 07 40 ff ff ff ff ff ff ff ff
0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff 7a a7

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
