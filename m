From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] tools/net: Use include/uapi with __EXPORTED_HEADERS__
Date: Thu, 12 Nov 2015 10:39:48 +0100
Message-ID: <56445E64.4070503@iogearbox.net>
References: <1447280667-1145-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Kamal Mostafa <kamal@canonical.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447280667-1145-1-git-send-email-kamal@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2015 11:24 PM, Kamal Mostafa wrote:
> Use the local uapi headers to keep in sync with "recently" added #define's
> (e.g. SKF_AD_VLAN_TPID).  Refactored CFLAGS, and bpf_asm doesn't need -I.
>
> Fixes: 3f356385e8a449e1d7cfc6b6f8d634ac4f5581a0
> Signed-off-by: Kamal Mostafa <kamal@canonical.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
