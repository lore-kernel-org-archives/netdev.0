From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver support
Date: Tue, 06 Mar 2012 16:41:47 +0100
Message-ID: <87r4x5u478.fsf@nemi.mork.no>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no>
	<878vjeuebk.fsf@nemi.mork.no> <20120306143559.GB23314@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48200 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab2CFPl4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 10:41:56 -0500
In-Reply-To: <20120306143559.GB23314@kroah.com> (Greg KH's message of "Tue, 6
	Mar 2012 06:35:59 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@linuxfoundation.org> writes:
> On Tue, Mar 06, 2012 at 01:03:11PM +0100, Bj=C3=B8rn Mork wrote:
>
>> I believe I may have promised to ping you when these patches were
>> ready.  Please apply patch 1-3 from this series to your usb-next bra=
nch
>> (for Linux 3.4). They were acked by Oliver a week ago.
>
> Great, can you resend them to me please, with Oliver's ack?  I don't =
see
> them in my to-apply queue anymore as I thought they were still under
> review.

OK. Will do.

>> Patches 4 and 5 (for netdev) will have to wait until the first 3 are
>> merged.
>
> I can take them through my tree if they are dependant on the first 3,
> that's not a problem.

I've managed to make them dependent on not-yet-merged patches in
net-next as well (the initial addition of the qmi_wwan driver), so I
believe that will be equally difficult.  Bad planning from my side I
guess...


Bj=C3=B8rn
