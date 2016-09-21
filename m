From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] BPF direct packet access improvements
Date: Tue, 20 Sep 2016 23:37:26 -0400 (EDT)
Message-ID: <20160920.233726.1046214138003718647.davem@davemloft.net>
References: <cover.1474323281.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbcIUDhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 23:37:33 -0400
In-Reply-To: <cover.1474323281.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 20 Sep 2016 00:26:11 +0200

> This set adds write support to the currently available read support
> for {cls,act}_bpf programs. First one is a fix for affected commit
> sitting in net-next and prerequisite for the second one, last patch
> adds a number of test cases against the verifier. For details, please
> see individual patches.

Series applied.
