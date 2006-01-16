From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 22:16:06 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0601162210550.17348@irie>
References: <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com>
 <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost>
 <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com>
 <20060115152034.GA1722@shaftnet.org> <Pine.LNX.4.58.0601152038540.19953@irie>
 <20060116170951.GA8596@shaftnet.org> <Pine.LNX.4.58.0601162020260.17348@irie>
 <20060116190629.GB5529@tuxdriver.com>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Stuffed Crust <pizza@shaftnet.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751192AbWAPUTY@vger.kernel.org>
To: "ext John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060116190629.GB5529@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2006, ext John W. Linville wrote:

> On Mon, Jan 16, 2006 at 08:51:31PM +0200, Samuel Ortiz wrote:
> > On Mon, 16 Jan 2006, ext Stuffed Crust wrote:
> >
> > > On Sun, Jan 15, 2006 at 09:05:33PM +0200, Samuel Ortiz wrote:
> > > > Regarding 802.11d and regulatory domains, the stack should also be able to
> > > > stick to one regulatory domain if asked so by userspace, whatever the APs
> > > > around tell us.
> > >
> > > ...and in doing so, violate the local regulatory constraints.  :)
> > The other option is to conform to whatever the AP you associate with
> > advertises. In fact, this is how it should be done according to 802.11d.
> > Unfortunately, this doesn't ensure local regulatory constraints compliance
> > unless you expect each and every APs to do the Right Thing ;-)
>
> If regulators come down on someone, it seems like common sense
> that they would be more lenient on mobile stations complying with a
> misconfigured AP than they would be with a mobile station ignoring a
> properly configured AP?  I know expecting common sense from government
> regulators is optimistic, but still... :-)
Well, I'd rather trust a governement regulated network than my neighbour's
AP ;-) In fact, some phones set their 802.11 regulatory domain based on
the information they received from a somehow government regulated network,
e.g. a GSM one.

Cheers,
Samuel.
