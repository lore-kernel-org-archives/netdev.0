From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (7/9) bridge - STP unsigned fields
Date: Fri, 16 Apr 2004 14:22:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416142209.04913f56.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413153046.4f47fe0f@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413153046.4f47fe0f@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:30:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Use correct types for fields related to spanning tree protocols.
>   * costs are 32 bit unsigned
>   * ports are 16 bit unsigned
>   * booleans are bytes rather than bitfield
>   * arrange for better packing

Applied.
