From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Issue with Micrel PCI Network Driver.
Date: Tue, 12 Feb 2013 13:40:40 +0100
Message-ID: <87d2w5k8mv.fsf@nemi.mork.no>
References: <51158774.8080405@novatechweb.com>
	<1360604764.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
	<1360604823.2701.11.camel@bwh-desktop.uk.solarflarecom.com>
	<87halhkfkc.fsf@nemi.mork.no>
	<1360670867.5374.249.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joseph.lutz@novatechweb.com>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54248 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933120Ab3BLMkw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:40:52 -0500
In-Reply-To: <1360670867.5374.249.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Tue, 12 Feb 2013 12:07:47 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:
> On Tue, 2013-02-12 at 11:10 +0100, Bj=C3=B8rn Mork wrote:
>
>> That should of course be fixed.  But this bug should not prevent
>> userspace from renaming the device, should it? Sounds like a userspa=
ce
>> application making too many stupid assumptions to me.  Does it work =
for
>> network devices attached to other buses?
>
> It prevents userspace from applying a naming policy that incorporates
> the PCI slot number.

Ah, right.  Thanks for explaining.  That makes more sense.


Bj=C3=B8rn
