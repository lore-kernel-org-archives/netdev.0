From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] netem - add correlated random number support
Date: Wed, 25 Aug 2004 16:52:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825165238.6a7c3678.davem@redhat.com>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
	<20040825110108.6a79216a@dell_ss3.pdx.osdl.net>
	<20040825161535.62f07a8c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040825161535.62f07a8c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Aug 2004 16:15:35 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Dave, this applies after "(4/4) netem - change parameters shouldn't destroy child qdisc"
> but before the patch to add loadable distributions, sorry for the confusion.

Just making sure you understand that I've rejected that whole
patch set because of the netem options structure breakage issue.
