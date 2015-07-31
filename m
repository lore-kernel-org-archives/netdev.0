From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2: ip batch processing problem
Date: Fri, 31 Jul 2015 07:49:35 +0200
Message-ID: <1438321775.20182.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAK4M3OjtNxB8xcmqQ1hVgbkV8i+=oOv9O8A1mMY2c_WM87a2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Antti Paila <antti.paila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36498 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbbGaFtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 01:49:40 -0400
Received: by wicgj17 with SMTP id gj17so2455116wic.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 22:49:39 -0700 (PDT)
In-Reply-To: <CAK4M3OjtNxB8xcmqQ1hVgbkV8i+=oOv9O8A1mMY2c_WM87a2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-31 at 08:34 +0300, Antti Paila wrote:

> Should the batch mode support mixed IPv4 and IPv6 addresses and if so,
> would it make sense to clear the 'preferred_family' variable
> before processing each line of the batch file?

This makes sense, please send a patch.

Thanks !
