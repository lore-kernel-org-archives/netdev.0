From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 02/13] ip_tunnels: use u8/u16/u32
Date: Wed, 19 Aug 2015 18:21:42 +0200
Message-ID: <20150819162142.GB3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <f404420d1cd268b77c8485df6a4a1fd562f9582d.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36822 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbHSQVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:21:45 -0400
Received: by wicja10 with SMTP id ja10so124447048wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:21:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f404420d1cd268b77c8485df6a4a1fd562f9582d.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> The ip_tunnels.h include file uses mixture of __u16 and u16 (etc.) types.
> Unify it to the non-underscore variants.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
