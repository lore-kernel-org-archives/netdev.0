From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: is there any plan to support BSD accept filter?
Date: Fri, 14 Jan 2005 14:05:40 -0800
Message-ID: <20050114140540.76146b29@dxpl.pdx.osdl.net>
References: <41E830BC.7000709@cs.princeton.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: KyoungSoo Park <kyoungso@cs.princeton.edu>
In-Reply-To: <41E830BC.7000709@cs.princeton.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If you want to do these kind of stateful hacks, why not build a
netfilter module to do it?


-- 
Stephen Hemminger	<shemminger@osdl.org>
