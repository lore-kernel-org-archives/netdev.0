From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netdev_ops
Date: Wed, 9 Jul 2003 14:14:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709181459.GE15293@gtf.org>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <3F0C4CA8.7090502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F0C4CA8.7090502@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 09, 2003 at 10:11:04AM -0700, Ben Greear wrote:
> Also, for the strings (labels) passed back to user space, is there any
> documentation for suggested values for these strings?  Even though we
> can't be completely type-safe, if there were suggested values in
> a comment in the code, it could help a great deal for any code trying to
> parse them for multiple different drivers/nics.

The strings represent NIC-specific attributes.

	Jeff
