From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] r8169: support RTL8106E
Date: Mon, 9 Jul 2012 12:12:15 +0200
Message-ID: <20120709101215.GA6530@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-2-git-send-email-hayeswang@realtek.com> <20120704220458.GA1621@electric-eye.fr.zoreil.com> <43E32504589B47B9846C4E9DAF98BF60@realtek.com.tw> <20120706152006.GA6981@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120708.234857.1032244145219683435.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
> Francois, what would you like me to do with these two patches?  I
> haven't seen full ACKs from you yet.

You have two options:
- You can apply the first (8106) patch. I tested it. I'm ok with Hayes point.
  Consider it Acked.
- You wait for a pull request with both patches + the incremental bits for
  the second one. Some of the incremental bits are needed in the original
  patch itself while some make more sense before the patch itself.
  ETA: this evening or tomorrow morning at worst.

If you go for the first option, I'll simply skip the first patch and
apply again. It's the same work for me.

-- 
Ueimor
