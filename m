From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Wed, 11 Jun 2014 12:17:18 +0200
Message-ID: <CAAP7ucKXPt=Ya3+mfVJ8rEjEkKabFrK0Z4Khaw7U6k-vUuU_Eg@mail.gmail.com>
References: <ln6m4k$q49$1@ger.gmane.org>
	<874mzt55kz.fsf@nemi.mork.no>
	<53971171.5070001@flokli.de>
	<539712BA.5010004@flokli.de>
	<87lht350y0.fsf@nemi.mork.no>
	<53982AA7.3090508@flokli.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org,
	"ModemManager (development)"
	<modemmanager-devel@lists.freedesktop.org>
To: Florian Klink <flokli@flokli.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56502 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaFKKRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 06:17:18 -0400
Received: by mail-ob0-f174.google.com with SMTP id va2so4135585obc.33
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 03:17:18 -0700 (PDT)
In-Reply-To: <53982AA7.3090508@flokli.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 12:08 PM, Florian Klink <flokli@flokli.de> wrote:
> Sure, I can provide the message dumps. Is it as simple as described in
> here (http://www.freedesktop.org/wiki/Software/ModemManager/Debugging/),
> or do I need to recompile libmbim + ModemManager with some additional (debug)
> flags enabled?


It's just like that; once you run MM with --debug you'll also get
libmbim debug messages as well, including all transactions going to
and from the modem.

-- 
Aleksander
https://aleksander.es
