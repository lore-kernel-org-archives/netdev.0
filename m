From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] e100: add support for 82552 10/100 adapter
Date: Thu, 19 Mar 2009 04:07:14 -0700
Message-ID: <9929d2390903190407l4796577bkd7163c8c1778dc10@mail.gmail.com>
References: <20090319104236.11320.25733.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:39069 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbZCSLHQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:07:16 -0400
Received: by yx-out-2324.google.com with SMTP id 31so466491yxl.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 04:07:14 -0700 (PDT)
In-Reply-To: <20090319104236.11320.25733.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 3:42 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>
> This patch enables support for the new Intel 82552 adapter (new PHY p=
aired
> with the existing MAC in the ICH7 chipset). =C2=A0No new features are=
 added to
> the driver, however there are minor changes due to updated registers =
and a
> few workarounds for hardware errata.
>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Sorry I left that off on the submission.

--=20
Cheers,
Jeff
