From: Thomas Graf <tgraf@suug.ch>
Subject: [ANNOUNCE] netlink library 0.5.0
Date: Tue, 5 Apr 2005 01:29:34 +0200
Message-ID: <20050404232934.GK26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I released libnl 0.5.0 today introducing address, routing,
and routing rules support, various cleanups, more callbacks
to customize message parsers, support for non-blocking
sockets and a complete API reference in HTML and PostScript.

About 70% of the features have been implemented of what
I would call the basics needed for a feature freeze
to let things stabilize for a 1.0 version.

http://people.suug.ch/~tgr/libnl/

http://people.suug.ch/~tgr/libnl/files/libnl-0.5.0.tar.gz

Summary of Changes from 0.4.4 to 0.5.0
================================================
	Thomas Graf <tgraf@suug.ch>
	  o API documentation
	  o nl_cache_filter to manually filter on a object
	  o partial routing support
	  o routing rules support
	  o Propely set address family when setting addresses
	  o debug flag and some rare messages, more to come
	  o make error mesage verboseness configureable
	  o tc fixes to wait for ack
	  o cleanup and adaption of address code to latest internal API
	  o various cleanups
	  o dozens of API breakages (better now than later)

	Daniel Hottinger <hotti@hotti.ch>
	  o arch 64bit printf length modifier fixes

	Baruch Even <baruch@ev-en.org>,
	Mediatrix Telecom, inc. <ericb@mediatrix.com>
	  o address support
