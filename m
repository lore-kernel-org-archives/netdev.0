From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: ctnetlink loop
Date: Fri, 3 Dec 2010 14:58:41 +0100
Message-ID: <20101203135841.GA23610@mail.eitzenberger.org>
References: <20101203133903.GG13225@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101203133903.GG13225@mail.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[changed netfilter-devel address]

I is even stuck for O_NONBLOCK sockets, which may be due to nfnl_mutex
being held in the receive path.

 /holger

