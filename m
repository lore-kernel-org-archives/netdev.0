From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix header size check for GSO case in recvmsg
 (af_packet)
Date: Wed, 10 Nov 2010 12:53:21 -0800 (PST)
Message-ID: <20101110.125321.179944968.davem@davemloft.net>
References: <1289253525-7020-1-git-send-email-mk@lab.zgora.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mk@lab.zgora.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289253525-7020-1-git-send-email-mk@lab.zgora.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <mk@lab.zgora.pl>
Date: Mon,  8 Nov 2010 22:58:45 +0100

> Parameter 'len' is size_t type so it will never get negative.
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Applied, thank you!
