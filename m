From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Tue, 09 Apr 2013 11:49:17 -0400
Message-ID: <5164387D.8080700@mojatatu.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com> <1365442863-32394-2-git-send-email-antonio@open-mesh.com> <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com> <20130409075606.GB3771@open-mesh.com> <51641049.3030100@mojatatu.com> <20130409135143.GA5177@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34470 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761783Ab3DIPtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:49:25 -0400
Received: by mail-ie0-f175.google.com with SMTP id c12so8489553ieb.6
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 08:49:24 -0700 (PDT)
In-Reply-To: <20130409135143.GA5177@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-04-09 09:51 AM, Antonio Quartulli wrote:

>
> Does this work at the bridge level? A packet entering a port and going out from
> another one can be affected by tc/mark?

Yes of course. And on any construct that looks like a netdev (tunnels etc).

cheers,
jamal
