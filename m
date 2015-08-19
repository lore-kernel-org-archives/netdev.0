From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 12/13] ipv6: route: extend flow
 representation with tunnel key
Date: Wed, 19 Aug 2015 20:00:04 +0200
Message-ID: <20150819180004.GC5564@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <eb93ff91f642c62fb269555006bcd0d7ebf7b69c.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33845 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbHSUra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:47:30 -0400
Received: by wicne3 with SMTP id ne3so136749874wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:47:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <eb93ff91f642c62fb269555006bcd0d7ebf7b69c.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:10pm, Jiri Benc wrote:
> Use flowi_tunnel in flowi6 similarly to what is done with IPv4.
> This complements commit 1b7179d3adff ("route: Extend flow representation
> with tunnel key").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
