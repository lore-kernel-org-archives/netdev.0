From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (6/9) bridge - forwarding database changes
Date: Fri, 16 Apr 2004 14:21:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416142101.52dfe6e9.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413152838.181eb743@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413152838.181eb743@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:28:38 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Make forwarding database more robust.  
>   + Don't insert invalid ether address,
>   + Report errors back so adding an interface to bridge can fail
>   + get rid of unneeded explicit pads in data structure
>   + replace bitfields with byte's for simple booleans.

Applied.
