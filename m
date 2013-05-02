From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 08:41:40 +0200
Message-ID: <20130502064140.GA21494@electric-eye.fr.zoreil.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
 <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> Any ideas?

1a9646497b163a8b9da5e70008d809dc91b32855 ("r8169: adjust the flow of hw_start"),
eee3786f7d3134e3edc54c1134511d520dd74285 ("r8169: Modify the method for setting
firmware") and 0427d0152eb3c2c2712afa427dd593c68fc09299
("r8169: Remove firmware code") may play a role on your 8168D setup, either by
themselves or combined with something else.

Expect no sign of life from me until the late end of the european working
hours.

-- 
Ueimor
