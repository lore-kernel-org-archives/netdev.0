From: bert hubert <ahu@ds9a.nl>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Thu, 5 Aug 2004 16:14:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805141444.GA2292@outpost.ds9a.nl>
References: <16224.1091629527@www2.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael T Kerrisk <mtk-lists@gmx.net>
Content-Disposition: inline
In-Reply-To: <16224.1091629527@www2.gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 04, 2004 at 04:25:27PM +0200, Michael T Kerrisk wrote:

> But on Linux (2.6), the bind() fails with EADDRINUSE.

This scenario has previously worked for me. Can you show the exact source
which exhibits this problem?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
