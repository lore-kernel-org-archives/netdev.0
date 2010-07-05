From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Mon, 5 Jul 2010 01:13:41 -0700
Message-ID: <AANLkTin4sdPeExcNJkq4pfwIq0lcJuXtzTAACRW3JTFh@mail.gmail.com>
References: <1277659633.2989.2.camel@localhost.localdomain>
	<1277659785.4028.1.camel@localhost.localdomain>
	<1277660638.3321.1.camel@localhost.localdomain>
	<1277660831.3321.3.camel@localhost.localdomain>
	<8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	<1277745247.12841.1.camel@localhost.localdomain>
	<8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	<1277807529.19417.2.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
	<1277938757.4138.3.camel@localhost.localdomain>
	<1278204106.21020.0.camel@localhost.localdomain>
	<1278283714.3444.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57733 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab0GEINm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:13:42 -0400
Received: by iwn7 with SMTP id 7so5268361iwn.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 01:13:41 -0700 (PDT)
In-Reply-To: <1278283714.3444.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 4, 2010 at 15:48, Maxim Levitsky <maximlevitsky@gmail.com> =
wrote:
> Did few guesses, and now I see that reverting the below commit fixes =
the
> problem.
>
> "e1000e: Fix/cleanup PHY reset code for ICHx/PCHx"
> e98cac447cc1cc418dff1d610a5c79c4f2bdec7f.
>
>
> Best regards,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Maxim Levitsky
>
> --

Can you give us till Tuesday to respond?  I know that there are some
additional e1000e patches in my queue, which may resolve the issue,
but this weekend the power is down to do some infrastructure upgrades
which prevents us from doing any investigation.debugging until
Tuesday.

--=20
Cheers,
Jeff
