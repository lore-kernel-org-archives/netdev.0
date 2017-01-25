From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] BPF tracepoints
Date: Wed, 25 Jan 2017 13:19:28 -0500 (EST)
Message-ID: <20170125.131928.1293307938933551620.davem@davemloft.net>
References: <cover.1485306168.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdAYSTa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:19:30 -0500
In-Reply-To: <cover.1485306168.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 25 Jan 2017 02:28:15 +0100

> This set adds tracepoints to BPF for better introspection and
> debugging. The first two patches are prerequisite for the actual
> third patch that adds the tracepoints. I think the first two are
> small and straight forward enough that they could ideally go via
> net-next, but I'm also open to other suggestions on how to route
> them in case that's not applicable (it would reduce potential
> merge conflicts on BPF side, though). For details, please see
> individual patches.

Looks great, series applied, thanks Daniel.
