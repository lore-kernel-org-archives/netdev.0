From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 (050124) release
Date: Mon, 24 Jan 2005 16:27:41 -0800
Message-ID: <20050124162741.41606e3f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <lartc-admin@mailman.ds9a.nl>
To: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Thanks to the work of Jamal and Thomas; here is an update to iproute2.

http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.10-ss050124.tar.gz

Changes since last version:
[Yun Mao]
	 fix typo in ss

[Thomas Graf]
	tc pedit/action cleanups
	add addraw_l
	rtattr_parse cleanups

[Jamal Hadi Salim]
	typo in m_mirred
	add support for pedit

[Jim Gifford]
	 Fix allocation size error in nomal and paretonormal generation
	 programs.

-- 
Stephen Hemminger	<shemminger@osdl.org>
_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
