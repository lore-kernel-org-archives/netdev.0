From: Albert ARIBAUD <albert.aribaud@3adev.fr>
Subject: Re: [PATCH] net: trivial: fix fsl fec_main mdio write return value
Date: Mon, 26 Sep 2016 21:15:28 +0200
Message-ID: <20160926211528.6a835cac.albert.aribaud@3adev.fr>
References: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jiri Kosina <trivial@kernel.org>, Fugang Duan <fugang.duan@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:22805 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965069AbcIZTPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 15:15:36 -0400
In-Reply-To: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... and of course I only see the typo /now/...

Le Mon, 26 Sep 2016 21:11:40 +0200, "Albert ARIBAUD (3ADEV)"
<albert.aribaud@3adev.fr> a écrit :

> If the MDIO enf-of-transfer wait loop does not time out,
              ~~~~~~~~~~~~~~~

Make that "end-of-transfer".

Should I post a v2?

Cordialement,
Albert ARIBAUD
3ADEV
