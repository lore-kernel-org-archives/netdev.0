From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/7] rocker: track when FDB entry is touched.
Date: Sat, 19 Sep 2015 08:31:40 +0200
Message-ID: <20150919063140.GB2067@nanopsycho.orion>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	pjonnala@broadcom.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com, andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34981 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbISGbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 02:31:43 -0400
Received: by wicge5 with SMTP id ge5so56322036wic.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 23:31:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1442606151-50429-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 18, 2015 at 09:55:45PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>The entry is touched once when created, and touched again for each update.
>The touched time is used to calculate FDB entry age.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
