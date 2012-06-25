From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 25 Jun 2012 22:25:30 +0200
Message-ID: <20120625202530.GC20195@electric-eye.fr.zoreil.com>
References: <20120602111335.0b94fb59@stein> <loom.20120611T175322-643@post.gmane.org> <20120611204925.GA7070@electric-eye.fr.zoreil.com> <CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com> <20120611215203.GA8860@electric-eye.fr.zoreil.com> <CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com> <20120612052631.GA14567@electric-eye.fr.zoreil.com> <CAMGsXDSsSMWfrV1vjnqkWH45ypZw+ZtYF7=ytc79MWRJ5RF5jQ@mail.gmail.com> <CAMGsXDRAE5RZduZnTRa-JmA9_N0Kv+juzYNB_0hf-x+Q8nkpSg@mail.gmail.com> <CAMGsXDSSCnOF+CykudBoEjTacSYL4LYG_ZnRTcS+Xzt54LW=Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57060 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756108Ab2FYUgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 16:36:08 -0400
Content-Disposition: inline
In-Reply-To: <CAMGsXDSSCnOF+CykudBoEjTacSYL4LYG_ZnRTcS+Xzt54LW=Og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomas Papan <tomas.papan@gmail.com> :
[...]
> Is there anything what can I provide or try? I do not want to be stuck
> on 3.2.x kernel.

You can try to revert 036dafa28da1e2565a8529de2ae663c37b7a0060

-- 
Ueimor
