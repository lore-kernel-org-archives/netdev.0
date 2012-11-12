From: David Miller <davem@davemloft.net>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH v2] r8169: Fix WoL on
 RTL8168d/8111d.
Date: Mon, 12 Nov 2012 18:27:54 -0500 (EST)
Message-ID: <20121112.182754.384199300061351360.davem@davemloft.net>
References: <20121101222113.GB7708@electric-eye.fr.zoreil.com>
	<20121112163858.GA4343@elie.Belkin>
	<20121112230339.GA28555@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jrnieder@gmail.com, stable@vger.kernel.org, kibi@debian.org,
	netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	florent.fourcot@enst-bretagne.fr
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121112230339.GA28555@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 13 Nov 2012 00:03:39 +0100

> Jonathan Nieder <jrnieder@gmail.com> :
> [...]
>> This has been applied as commit b00e69dee4cc in mainline; thanks!
>> 
>> Fran??ois and David, would this be a candidate for inclusion in
>> 3.0- and newer stable kernels?
> 
> - 3.0.51
>   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
>   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> 
> - 3.4.18
>   0481776b7a70f09acf7d9d97c288c3a8403fbfe4
>   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
>   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> 
> - 3.6.6
>   0481776b7a70f09acf7d9d97c288c3a8403fbfe4
>   b00e69dee4ccbb3a19989e3d4f1385bc2e3406cd
>   aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
> 
> I'll cook the patches.

Thank you, these all look fine for -stable to me.
