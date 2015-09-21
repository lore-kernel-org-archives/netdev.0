From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 4/7] rocker: adding port ageing_time for
 ageing out FDB entries
Date: Mon, 21 Sep 2015 08:49:33 +0200
Message-ID: <20150921064933.GB2141@nanopsycho.orion>
References: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
 <1442764109-11110-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36625 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbbIUGtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 02:49:36 -0400
Received: by wicgb1 with SMTP id gb1so100420373wic.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 23:49:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442764109-11110-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Sep 20, 2015 at 05:48:26PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Follow-up patcheset will allow user to change ageing_time, but for now
>just hard-code it to a fixed value (the same value used as the default
>for the bridge driver).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
