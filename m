From: =?UTF-8?B?QXVyw6lsaWVu?= <footplus@gmail.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Fri, 9 Nov 2012 16:31:17 +0100
Message-ID: <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com> <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: footplus@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:47070 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab2KIPbj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:31:39 -0500
Received: by mail-qa0-f46.google.com with SMTP id c11so275560qad.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 07:31:38 -0800 (PST)
In-Reply-To: <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 9, 2012 at 4:08 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
>
> No, the driver also needs to implement ethtool_ops::get_module_info a=
nd
> ethtool_ops::get_module_eeprom.  But those should be quite easy to do=
=2E
>

Indeed. But like you said, it should be easy. I shall receive my cards
on monday, i'll try to do the implementation next week.

Best regards,
--=20
Aur=C3=A9lien Guillaume
- By all means break the rules, and break them beautifully,
deliberately and well. That is one of the ends for which they exist.
-- Robert Bringhurst
