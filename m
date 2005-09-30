From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 version (050929)
Date: Fri, 30 Sep 2005 15:04:06 -0700
Message-ID: <20050930150406.2e2221fd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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

There is an new minor update to iproute2 utilities available:
	http://developer.osdl.org/dev/iproute2/download/iproute2-050929.tar.gz

Also, this (and future) releases are now signed, for key info read:
	http://developer.osdl.org/dev/iproute2/signature.html

[Stephen Hemminger]
	Fix uninitialized memory and leaks
	Add -batch option to ip.
	Update to 2.6.14 headers

[Arnaldo]
        Integrate support for DCCP into 'ss'

[Mike Frysinger]
	Fix build issues with netem tables (parallel make and HOSTCC)

[Eric Dumazet]
	Fix lnstat : First column should not be summed


-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
