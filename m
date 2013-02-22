From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: xen-netback fixes for stable 35876b5 3e55f8b
Date: Fri, 22 Feb 2013 17:44:28 +0000
Message-ID: <1361555068.26546.144.camel@zakaz.uk.xensource.com>
References: <20130222164728.GB27794@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"Christopher S. Aker" <caker@theshore.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: William Dauchy <william@gandi.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130222164728.GB27794@gandi.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding Dave Miller, the networking maintainer. He needs to ack such
requests I think. Adding netdev too for good meassure.

On Fri, 2013-02-22 at 16:47 +0000, William Dauchy wrote:
> Hello,
> 
> I believe the two commits 35876b5 and 3e55f8b could be included in stable tree.
> 35876b5 is related to 4885628 already in the stable tree and fixes a
> possible oops.
> 3e55f8b is fixing another possible oops (see commit messages).

DaveM has these queued for stable already:
http://marc.info/?l=xen-devel&m=136086628711282&w=2

He likes to soak thing in mainline for a bit before forwarding to stable
which is likely why they aren't there yet
http://marc.info/?l=xen-devel&m=136029801624783&w=2

Ian.
