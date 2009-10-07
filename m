From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Bug #14261] e1000e jumbo frames no longer work: 'Unsupported MTU
	setting'
Date: Wed, 7 Oct 2009 12:12:45 -0700
Message-ID: <9929d2390910071212o632196b8o92899565bb131cea__35517.1214243912$1254943152$gmane$org@mail.gmail.com>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.jd.5MTxKB@chimera>
	 <877hvd8rj5.fsf@spindle.srvr.nix> <200910022331.35916.rjw@sisk.pl>
	 <9929d2390910021513t51827031k16a5bfc538640cbf@mail.gmail.com>
	 <20091007183453.GD12971@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Theodore Tso <tytso@mit.edu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Nix <nix@esperi.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kern
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:40345 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206AbZJGTNW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 15:13:22 -0400
In-Reply-To: <20091007183453.GD12971@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2009 at 11:34, Theodore Tso <tytso@mit.edu> wrote:
> On Fri, Oct 02, 2009 at 03:13:07PM -0700, Jeff Kirsher wrote:
>> >> > Patch =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : http:/=
/patchwork.kernel.org/patch/50277/
>> >>
>> > Most likely because it's not in the Linus' tree yet.
>> >
>> > [e1000e maintainers, we have a regression fix to merge, please.]
>>
>> Sorry, I forgot to send this patch out last night. =C2=A0I will send=
 it now.
>
> Do we have a status on this progress of this patch to mainline? =C2=A0=
 Thanks,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-=
 Ted

The patch has been submitted and accepted into David Miller's net-2.6
tree.  I will submit the patch for 2.6.31 stable tree once it makes it
into Linus's tree later this week.

--=20
Cheers,
Jeff
