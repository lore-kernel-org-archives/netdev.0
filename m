From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: ixp4xx_hss MAX_CHAN_DEVICES
Date: Wed, 19 Nov 2008 12:17:56 +0100
Message-ID: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.186]:12767 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbYKSLR5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 06:17:57 -0500
Received: by rn-out-0910.google.com with SMTP id k40so2794395rnd.17
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 03:17:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am interested in modifying ixp4xx_hss so that 4*32 channels can be
used for each hss device.

My first option is to modify the "defines" placed in the driver, but I
wonder if it would be useful to modify hss_plat_info to set this kind
of info.

Any comments on this?

Thanks

Miguel =C1ngel =C1lvarez
