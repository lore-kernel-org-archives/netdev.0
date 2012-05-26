From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [ANNOUNCE] libmnl 1.0.3 release
Date: Sat, 26 May 2012 20:24:38 +0200
Message-ID: <20120526182438.GA32201@1984>
References: <20120526182350.GB32109@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120526182350.GB32109@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 26, 2012 at 08:23:50PM +0200, Pablo Neira Ayuso wrote:
> Hi!
> 
> The Netfilter project proudly presents:
> 
>         libmnl 1.0.3
> 
> libmnl is a minimalistic (really!) library that provides simple
> abstractions to communicate using Netlink sockets.
> 
> If you're looking for a way to communicate some kernel subsystem and
> user-space, Netlink provides a nice method to do so. For those not yet
> familiar with Netlink, I suggest you to read:
> 
> http://1984.lsi.us.es/~pablo/docs/spae.pdf
> 
> This release include one fix and one new interface to allow to parse
> messages from some payload offset, skipping the Netlink header. See
> ChangeLog that comes attached to this email for more details.

Forgot to attach changelog, sorry.

> You can download it from:
> 
> http://www.netfilter.org/projects/libmnl/downloads.html
> ftp://ftp.netfilter.org/pub/libmnl/
> 
> Have fun!

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libmnl-1.0.3.txt"

Pablo Neira Ayuso (1):
      parse: add mnl_attr_for_each_payload

Stephen Hemminger (1):
      nlmsg: fix valgrind warnings about padding


--CE+1k2dSO48ffgeK--
