From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/7] rocker: store rocker_port in fdb key rather
 than pport
Date: Sat, 19 Sep 2015 08:31:52 +0200
Message-ID: <20150919063152.GC2067@nanopsycho.orion>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33916 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbISGbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:31:55 -0400
Received: by wicfx3 with SMTP id fx3so87208415wic.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:31:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442606151-50429-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 18, 2015 at 09:55:46PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>We'll need more info from rocker_port than just pport when we age out fdb
>entries, so store rocker_port rather than pport in each fdb entry.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
