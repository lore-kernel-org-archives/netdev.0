From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC: 2.6 patch] let NET_CLS_ACT no longer depend on EXPERIMENTAL
Date: Sat, 04 Mar 2006 17:56:26 +0100
Message-ID: <4409C6BA.60803@trash.net>
References: <20060304160755.GB9295@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932208AbWCDQ4a@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060304160755.GB9295@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This option should IMHO no longer depend on EXPERIMENTAL.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> ---
> 
> This patch was already sent on:
> - 12 Feb 2006

Yesterday I managed to crash my machine playing around with tc actions
within minutes. I haven't looked into it yet, but it seems it still
needs more testing.
