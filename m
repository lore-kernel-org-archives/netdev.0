From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master] tc, bpf: make sure relo is in relation
 with map section
Date: Tue, 2 Feb 2016 16:06:34 +1100
Message-ID: <20160202160634.7e87e80c@samsung9>
References: <6f06b68f62c89489ec1afea5ba1c328ef51efd10.1453418999.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33795 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbcBBFGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 00:06:42 -0500
Received: by mail-pf0-f177.google.com with SMTP id o185so91553736pfb.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 21:06:42 -0800 (PST)
In-Reply-To: <6f06b68f62c89489ec1afea5ba1c328ef51efd10.1453418999.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Jan 2016 00:46:28 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Add a test that symbol from relocation entry is actually related
> to map section and bail out with an error message if it's not the
> case; in relation to [1].
> 
>   [1] https://llvm.org/bugs/show_bug.cgi?id=26243
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Applied
