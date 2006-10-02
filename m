From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2-2.6.18-061002
Date: Mon, 2 Oct 2006 13:55:52 -0700
Message-ID: <20061002135552.4acb6892@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, linux-kernel@vger.kernel.rog
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

This is a much delayed update to the iproute2 command set.
It can be downloaded from:
  http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.18-061002.tar.gz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

For more info on iproute2 see:
  http://linux-net.osdl.org/index.php/Iproute2

The version number includes the kernel version to denote what features are
supported. The same source should build on older systems, but obviously the
newer kernel features won't be available. As much as possible, this package
tries to be source compatible across releases.

Summary of changes:
	- converted to git
	- build fixes for some distributions
	- bug fix for xfrm monitor
	- alignment fixes for cris
	- documentation corrections
	- many small bug fixes
	- new tc monitor mode

Contributors to this release
	Jamal Hadi Salim
	Patrick McHardy
	Andy Gay
	Jesper Dangaard Brouer
	Vince Worthington 
	
Git changelog is a bit of a mess, so if I missed your name sorry.
