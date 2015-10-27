From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: sample: define aarch64 specific registers
Date: Mon, 26 Oct 2015 20:22:24 -0700
Message-ID: <20151027032223.GA26748@Alexeis-MacBook-Pro.local>
References: <1445904139-19212-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org
To: Yang Shi <yang.shi@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34841 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbJ0DW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 23:22:28 -0400
Content-Disposition: inline
In-Reply-To: <1445904139-19212-1-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 05:02:19PM -0700, Yang Shi wrote:
> Define aarch64 specific registers for building bpf samples correctly.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

looks good to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
