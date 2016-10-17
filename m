From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: cls_bpf: handle skip_sw and skip_hw flags
Date: Mon, 17 Oct 2016 05:28:30 -0700
Message-ID: <20161017052830.47de0a21@xeon-e3>
References: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34057 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934588AbcJQM2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:28:16 -0400
Received: by mail-pa0-f50.google.com with SMTP id rz1so63096950pab.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 05:28:15 -0700 (PDT)
In-Reply-To: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Oct 2016 16:46:36 +0100
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> Add support for controling hardware offload using (now standard)
> skip_sw and skip_hw flags in cls_bpf.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied
