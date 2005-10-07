From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 (051007)
Date: Fri, 7 Oct 2005 15:43:44 -0700
Message-ID: <20051007154344.400dd82b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl
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

Fix one serious bug (in libnetlink), and a couple of other minor
patches.

http://developer.osdl.org/dev/iproute2/download/iproute2-051007.tar.gz

Stephen Hemminger
	 Reenable ip mroute

Mike Frysinger
	Handle pfifo_fast that has no qopt without segfaulting

Mads Martin Joergensen
	Trivial netem ccopts

Jerome Borsboom
	Fix regression in ip addr (libnetlink) handling


-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
