From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: minor: fix kdoc in __sk_run_filter
Date: Tue, 01 Apr 2014 15:26:13 -0400 (EDT)
Message-ID: <20140401.152613.1187865040678935534.davem@davemloft.net>
References: <c632c48561df232d14dd87d68b3b322db110e8aa.1396373788.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org, ast@plumgrid.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaDAT0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:26:14 -0400
In-Reply-To: <c632c48561df232d14dd87d68b3b322db110e8aa.1396373788.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  1 Apr 2014 19:38:01 +0200

> This minor patch fixes the following warning when doing
> a `make htmldocs`:
> 
>   DOCPROC Documentation/DocBook/networking.xml
> Warning(.../net/core/filter.c:135): No description found for parameter 'insn'
> Warning(.../net/core/filter.c:135): Excess function parameter 'fentry' description in '__sk_run_filter'
>   HTML    Documentation/DocBook/networking.html
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
