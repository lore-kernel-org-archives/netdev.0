From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fw: [Bug 64081] New: mdiobus_read fail and return -110 when
 called from get_phy_id r6040: 0000:00:08.0 failed to register MII bus
Date: Wed, 30 Oct 2013 11:33:17 -0700
Message-ID: <CAGVrzcZZd-6xnTW4ks-DExKwyzegY_gNEo1oRuFHZn9BWvOPJg@mail.gmail.com>
References: <20131030112348.58ceec8a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44050 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab3J3Sd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:33:58 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1343046pab.6
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 11:33:58 -0700 (PDT)
In-Reply-To: <20131030112348.58ceec8a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/30 Stephen Hemminger <stephen@networkplumber.org>:
>
>
> Begin forwarded message:
>
> Date: Wed, 30 Oct 2013 11:10:47 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 64081] New: mdiobus_read fail and return -110 when called from get_phy_id  r6040: 0000:00:08.0 failed to register MII bus

Thanks Stephen, investigating with the reporter of the bug.
--
Florian
