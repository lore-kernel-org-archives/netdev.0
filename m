From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (1/9) bridge - include file cleanup
Date: Fri, 16 Apr 2004 14:12:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416141257.345e916b.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:16:30 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Cleanup some of the include file's in the bridge code.
> * if_bridge.h defines net_bridge, but not needed as part of the API.
> * get rid of places that include if_bridge.h and uaccess.h but don't
>   actually do API work.

Applied.
