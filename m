From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon, 9 Feb 2015 12:55:46 +0100
Message-ID: <CAKfDRXhW-izhes0qq2qJA0ojm37Eg=dybYSdzo8u-VzhT15EGw@mail.gmail.com>
References: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
	<87a90nqp45.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:55734 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759515AbbBILzr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 06:55:47 -0500
Received: by mail-yk0-f182.google.com with SMTP id q9so11069671ykb.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 03:55:46 -0800 (PST)
In-Reply-To: <87a90nqp45.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Feb 9, 2015 at 12:51 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Just to be sure: You do have a configuration where interfaces #10 and
> #11 are visible, but none of them respond to any QMI at all?  Not eve=
n
> CTL SYNC?  Could you get a minimal usbmon trace of that?

Yes, that is correct. I will get hold of the device with the card in
it and run another test to provide the trace. The model is MC7304 btw.

Thanks for all the additional info.

-Kristian
