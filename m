From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 4/7] rocker: adding port ageing_time for
 ageing out FDB entries
Date: Wed, 23 Sep 2015 17:49:54 +0200
Message-ID: <20150923154954.GB11681@nanopsycho.orion>
References: <1443022760-21301-1-git-send-email-sfeldma@gmail.com>
 <1443022760-21301-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36083 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbIWPt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:49:56 -0400
Received: by wicgb1 with SMTP id gb1so211996865wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:49:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1443022760-21301-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 23, 2015 at 05:39:17PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Follow-up patcheset will allow user to change ageing_time, but for now
>just hard-code it to a fixed value (the same value used as the default
>for the bridge driver).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
