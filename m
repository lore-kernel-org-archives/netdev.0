From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169 warning from 64 bit constant
Date: Mon, 3 May 2004 22:19:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040503221939.A4612@electric-eye.fr.zoreil.com>
References: <20040503110517.3a144b46@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040503110517.3a144b46@dell_ss3.pdx.osdl.net>; from shemminger@osdl.org on Mon, May 03, 2004 at 11:05:17AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> Need 'ull' on end of a 64 bit constant to get rid of warning.

It is included in the patch 2/7 of the serie which has been sent the first
of may 2005 (actually it was already in Andy Lutomirski's first patch).

--
Ueimor
