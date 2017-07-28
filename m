From: David Miller <davem@davemloft.net>
Subject: Re: STABLE: net: reduce skb_warn_bad_offload() noise
Date: Fri, 28 Jul 2017 12:30:10 -0700 (PDT)
Message-ID: <20170728.123010.242124876818464581.davem@davemloft.net>
References: <4b5d320a-a12e-b27b-cc58-332614684bf2@android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: salyzyn@android.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <4b5d320a-a12e-b27b-cc58-332614684bf2@android.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Salyzyn <salyzyn@android.com>
Date: Fri, 28 Jul 2017 10:29:57 -0700

> Please backport the upstream patch to the stable trees (including
> 3.10.y, 3.18.y, 4.4.y and 4.9.y):
> 
> b2504a5dbef3305ef41988ad270b0e8ec289331c net: reduce
> skb_warn_bad_offload() noise
> 
> Impacting performance or creating unnecessary alarm, and will result
> in kernel panic for panic_on_warn configuration.

Yeah this is fine.
