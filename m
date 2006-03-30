From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] deinline some larger functions from netdevice.h
Date: Wed, 29 Mar 2006 23:28:17 -0800
Message-ID: <20060329232817.317def39.akpm@osdl.org>
References: <200603301021.48925.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751306AbWC3H3A@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200603301021.48925.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@ilport.com.ua> wrote:
>
> Network folks did non comment on these two patches, let me try
>  submitting them to you instead.

They're both merged (one is in -linus, the other's in -davem).
