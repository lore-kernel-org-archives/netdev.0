From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver support
Date: Fri, 09 Mar 2012 10:29:43 +0100
Message-ID: <877gyucebc.fsf@nemi.mork.no>
References: <20120306143559.GB23314@kroah.com> <87r4x5u478.fsf@nemi.mork.no>
	<20120308185324.GA13836@kroah.com>
	<20120308.134338.1946356302291460775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	dcbw@redhat.com, oliver@neukum.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37690 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab2CIJaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 04:30:46 -0500
In-Reply-To: <20120308.134338.1946356302291460775.davem@davemloft.net> (David
	Miller's message of "Thu, 08 Mar 2012 13:43:38 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Thu, 8 Mar 2012 10:53:24 -0800
>
>> On Tue, Mar 06, 2012 at 04:41:47PM +0100, Bj=C3=B8rn Mork wrote:
>>> I've managed to make them dependent on not-yet-merged patches in
>>> net-next as well (the initial addition of the qmi_wwan driver), so =
I
>>> believe that will be equally difficult.  Bad planning from my side =
I
>>> guess...
>>=20
>> I can take those patches as well if needed, to help unwind the
>> dependancy mess, and the network maintainer doesn't mind.
>
> I don't mind :)

Great. Thanks.

I'll resend patch 4 and 5 of this series to Greg then, noting the
necessary commit IDs from net-next in the cover letter.


Bj=C3=B8rn
