From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 util update
Date: Tue, 16 Aug 2005 14:34:16 -0700
Message-ID: <20050816143416.61c10513@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
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

http://developer.osdl.org/dev/iproute2/download/iproute2-050816.tar.gz

Update to iproute2 to include:
	* Limit ip neigh flush to 10 rounds
	* tc ematch support (thomas)
	* build cleanups (thomas, et al)
	* Fix for options process with ipt (jamal)
	* Fix array overflow in paretonormal distribution build
	* Update include files to 2.6.13
	* Decnet doc update (Steven Whithouse)

Note: the ematch support won't build on really old versions of bison (1.28),
      but the kernel on those systems wouldn't support it anyway.
