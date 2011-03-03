From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 3/5] tg3: Enclose macro with complex values in parenthesis
Date: Thu, 3 Mar 2011 12:54:52 +0100
Message-ID: <AANLkTinjaRMUgr_N4v_63ExrqJsU_i47Q3_xwQQN9CiA@mail.gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
 <1298999069-12740-3-git-send-email-martinez.javier@gmail.com> <20110302.205601.71129255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	kernelnewbies@kernelnewbies.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47069 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab1CCLzI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 06:55:08 -0500
Received: by wyg36 with SMTP id 36so950323wyg.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 03:55:07 -0800 (PST)
In-Reply-To: <20110302.205601.71129255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This seems unnecessary, what problem do the current macro definitions
> create?
>

Probably the change is unnecessary, the only value is that it silences
a checkpatch error:

ERROR: Macros with complex values should be enclosed in parenthesis

Sorry for the noise.

--=20
-----------------------------------------
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
PhD Student in High Performance Computing
Computer Architecture and Operating System Department (CAOS)
Universitat Aut=C3=B2noma de Barcelona
Barcelona, Spain
