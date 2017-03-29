From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] Revert "net: stmmac: enable multiple buffers"
Date: Wed, 29 Mar 2017 08:32:05 +0200
Message-ID: <20170329063205.GA13184@Red>
References: <20170329050540.12392-1-clabbe.montjoie@gmail.com>
 <20170328.221123.114918336450977007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao.Pinto@synopsys.com,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36637 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753165AbdC2GcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:32:13 -0400
Content-Disposition: inline
In-Reply-To: <20170328.221123.114918336450977007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 10:11:23PM -0700, David Miller wrote:
> 
> Did you even test all 3 of Thierry's patches?
> 
> I want you to do that before we revert.
> 

Yes I tested all 3, dwmac-sunxi is still broken with them
