From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 13:16:17 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610171617.GC1959@gtf.org>
References: <Pine.LNX.4.44.0306101801070.26879-100000@kenzo.iwr.uni-heidelberg.de> <20030610162029.GA8168@wotan.suse.de> <20030610162342.GB1959@gtf.org> <20030610.100209.70199702.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de,
	hadi@shell.cyberus.ca, ralph+d@istop.com, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030610.100209.70199702.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2003 at 10:02:09AM -0700, David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@pobox.com>
>    Date: Tue, 10 Jun 2003 12:23:42 -0400
>    
>    I prefer a compile-time test.
> 
> This means end users don't see the benefit, so I definitely
> prefer Andi's idea.

Making every IO a conditional branch?  Ug.

	Jeff



