From: "Michael Renzmann" <madwifi@nospam.otaku42.de>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Tue, 5 Dec 2006 15:39:06 +0100 (CET)
Message-ID: <3459.194.45.26.221.1165329546.squirrel@webmail.otaku42.de>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
    <200611291612.33448.mb@bu3sch.de>
    <20061129152407.GB5412@devicescape.com>
    <200611291638.56759.mb@bu3sch.de>
    <20061129160328.GA22602@devicescape.com>
    <20061129121312.4cfc254f@freekitty>
    <43e72e890612011035hf24aeb6wd20f8e93d2238c68@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net,
	"Nick Kossifidis" <mickflemm@gmail.com>,
	"Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from legolas.otaku42.de ([217.24.0.78]:37733 "EHLO
	legolas.otaku42.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967460AbWLEOjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 09:39:22 -0500
In-Reply-To: <43e72e890612011035hf24aeb6wd20f8e93d2238c68@mail.gmail.com>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all.

> To make things easier for development I'd like to suggest a few madwif
> ibranches created:
>
> * madwifi-1152-openhal: based on madwifi-1152, patched with my patch,
> added openhal, old hal removed. Working free solution. Should exist
> just as a reference and to allow users to checkout a working free
> alternative in the mean time.
>
> * madwifi-dadwifi-openal: based on the latest dadwifi with the
> openhal, old hal removed. As dadwifi gets updated you can pull updates
> to this branch. As the openhal advances you can make updates to the
> openhal here.

I've set up the suggested branches, with slight changing to the proposed
names:

* http://svn.madwifi.org/branches/madwifi-old-openhal (based on r1142)
* http://svn.madwifi.org/branches/dadwifi-openhal (based on r1827)

Neither of them has received any modifications yet, they are basically
copies of the mentioned revisions. I'm currently lacking the time to
import Nick's work into the madwifi-old-openhal branch, for example - it
would be nice if someone else could work on that.

The MadWifi project happily provides any interested party access to the
resources we have at hands - including (but not limited to) r/w access to
the repository, an account for our Trac (used to manage tickets for bugs,
patches, ...), e-mail, .... Let me know if you need something in that
regard and I'll try to get it done. We'd love to support these efforts
where possible.

Bye, Mike

