From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master] {f,m}_bpf: dump tag over insns
Date: Thu, 23 Feb 2017 09:02:44 -0800
Message-ID: <20170223090244.73702374@xeon-e3>
References: <ca13968c577a5b3b9cbdb0aeaf637b7b7c168e69.1487850643.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34980 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751397AbdBWRDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:03:08 -0500
Received: by mail-pf0-f178.google.com with SMTP id 68so4754678pfx.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 09:02:47 -0800 (PST)
In-Reply-To: <ca13968c577a5b3b9cbdb0aeaf637b7b7c168e69.1487850643.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Feb 2017 13:07:14 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> We already export TCA_BPF_TAG resp. TCA_ACT_BPF_TAG from kernel commit
> f1f7714ea51c ("bpf: rework prog_digest into prog_tag"), thus also dump
> it when filter/actions are shown.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied
