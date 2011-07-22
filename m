From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: make function can_get_bittiming static
Date: Thu, 21 Jul 2011 21:35:07 -0700 (PDT)
Message-ID: <20110721.213507.1929766655763148125.davem@davemloft.net>
References: <1311301351-5298-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, srcvale@holoscopio.com
To: cascardo@holoscopio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311301351-5298-1-git-send-email-cascardo@holoscopio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Date: Thu, 21 Jul 2011 23:22:31 -0300

> The function can_get_bittiming is not used anywhere else, so it should be
> static.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

Applied.
