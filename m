From: Daniel Roesen <dr@cluenet.de>
Subject: Re: [PATCH] net/ipv4 for Source VIPA support, kernel BK Head
Date: Mon, 6 Sep 2004 01:02:19 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040905230219.GA24688@srv01.cluenet.de>
References: <200409011441.10154.elueck@de.ibm.com> <Pine.LNX.4.61.0409011852380.2441@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml@einar-lueck.de, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267326AbUIEXCX@vger.kernel.org>
To: Paul Jakma <paul@clubi.ie>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0409011852380.2441@fogarty.jakma.org>
List-Id: netdev.vger.kernel.org

On Thu, Sep 02, 2004 at 05:22:01PM +0100, Paul Jakma wrote:
> ip route add default via <gateway> src <virtual ip>

Sitenote: unfortunately, "src <...>" doesn't work for IPv6 routes, at
least in 2.4 -- can someone confirm this problem to still exist in
current 2.6?

Copying netdev for the record.


Regards,
Daniel
