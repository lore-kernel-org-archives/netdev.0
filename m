From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] irda: Use __packed annotation instead IRDA_PACKED
 macro
Date: Wed, 21 Jul 2010 14:10:00 -0700 (PDT)
Message-ID: <20100721.141000.150174979.davem@davemloft.net>
References: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: padovan@profusion.mobi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Date: Wed, 21 Jul 2010 17:59:57 -0300

> Remove IRDA_PACKED macro, which maps to __attribute__((packed)). IRDA is
> one of the last users of __attribute__((packet)). Networking code uses
> __packed now.
> 
> Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>

Applied.
