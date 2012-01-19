From: Simon Chen <simonchennj@gmail.com>
Subject: Re: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s
 X520-DA2 NIC?
Date: Wed, 18 Jan 2012 21:55:47 -0500
Message-ID: <CANj2Ebf_W9qkO38v9D4wLXMk0ekbbNBDZ8yoRR9E0mWq2i-6fw@mail.gmail.com>
References: <1326886258.19261.25.camel@probook>
	<20120118091351.000052fc@unknown>
	<m3d3ag7ki8.fsf@ursa.amorsen.dk>
	<9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
	<20120119011221.GR5069@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56871 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752902Ab2ASCzt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 21:55:49 -0500
Received: by werb13 with SMTP id b13so877099wer.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 18:55:48 -0800 (PST)
In-Reply-To: <20120119011221.GR5069@angus.ind.WPI.EDU>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If short-range is fine for you, twinax is awesome...

On Wed, Jan 18, 2012 at 8:12 PM, Chuck Anderson <cra@wpi.edu> wrote:
> On Wed, Jan 18, 2012 at 10:21:58PM +0000, Fujinaka, Todd wrote:
>> That's up to you. There's "locked" and there's "locked". I'm surpris=
ed
>> that Benny and Jesper haven't looked at the driver to see where the
>> messages come from.
>>
>> We have a short list of optical modules that have been tested with o=
ur
>> cards. The problem with standards is that there's always some wiggle
>> room and you won't know if something really works until you try it. =
No
>> matter how large the company, we are still constrained as far as wha=
t we
>> can do in a day and testing every module we can find just wasn't one=
 of
>> the things that was approved for us to try.
>
> I don't buy that argument.
>
> We have Ethernet standards and we have IP standards and we have
> SFP/SFP+ standards. =A0Did you test your 1000Base-T copper Ethernet
> cards with every vendor of Ethernet hardware? =A0If not, did you lock
> them out to talk to only "pre-approved" Ethernet switches? =A0Would y=
ou
> have done so if there was a way to technically do so (perhaps via
> LLDP)?
>
> What about USB keyboards/mice? =A0Maybe Intel's chipsets can be locke=
d
> so only Intel USB keyboards work...and then we can all stop buying
> Intel hardware.
>
> The hardware and drivers should not be enforcing specific optics. =A0=
If
> a user buys a crap optic, then that is their problem. =A0Just like if
> they plug a crappy Cat3 RJ45 cable between the 1000Base-T NIC and the
> switch.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
