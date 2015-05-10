From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 23/24] rocker: make checkpatch -f clean
Date: Sun, 10 May 2015 22:07:52 +0200
Message-ID: <20150510200752.GH2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-24-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34229 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbEJUIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 16:08:00 -0400
Received: by wgic8 with SMTP id c8so84985125wgi.1
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 13:07:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-24-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:48:08PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Well almost clean: ignore the CHECKs for space after cast operator and some
>longer-than-80 char cases where for readability it's better to keep as-is.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
