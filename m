From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] netem limit not returned correctly
Date: Tue, 3 Aug 2004 14:24:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803142431.0d5d669a.davem@redhat.com>
References: <20040803131111.6ce2c36c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803131111.6ce2c36c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 13:11:11 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Minor leftover from earlier code.  Netem scheduler is not reporting
> correct limit (ie for 'tc qdisc ls') because it is returning devices limit
> not it's own.
> 
> Should apply to 2.4 as well (with fuzz)

Applied to both trees, thanks Stephen.
