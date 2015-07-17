From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 1/3] rhashtable: Allow lookup function to
 have compare function agument
Date: Fri, 17 Jul 2015 14:08:22 +0200
Message-ID: <20150717120822.GD18033@pox.localdomain>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
 <1436917549-3666965-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37139 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465AbbGQMI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:08:26 -0400
Received: by wibud3 with SMTP id ud3so40992881wib.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 05:08:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436917549-3666965-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/15 at 04:45pm, Tom Herbert wrote:
> Added rhashtable_lookup_fast_cmpfn which does a lookup in an rhash table
> with the compare function being taken from an argument. This allows
> different compare functions to be used on the same table.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
