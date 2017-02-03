From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] trace: rename trace_print_hex_seq arg and add
 kdoc
Date: Fri, 03 Feb 2017 15:50:45 -0500 (EST)
Message-ID: <20170203.155045.1099357457146606258.davem@davemloft.net>
References: <fefa5048a9834e7857fa399dc800054d4cebdd31.1486050724.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdBCUur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:50:47 -0500
In-Reply-To: <fefa5048a9834e7857fa399dc800054d4cebdd31.1486050724.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  2 Feb 2017 17:09:54 +0100

> Steven suggested to improve trace_print_hex_seq() a bit after commit
> 2acae0d5b0f7 ("trace: add variant without spacing in trace_print_hex_seq")
> in two ways: i) by adding a kdoc comment for the helper function
> itself and ii) by renaming 'spacing' argument into 'concatenate'
> to better denote that we don't add spaces between each hex bytes.
> 
> Suggested-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  [ Sending as follow-up as original one is in net-next. ]

Applied, thanks Daniel.
