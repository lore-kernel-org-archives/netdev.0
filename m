From: "David S. Miller" <davem@redhat.com>
Subject: Re: off by one error in 3des cbc keying
Date: Wed, 13 Nov 2002 00:45:02 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021113.004502.22547554.davem@redhat.com>
References: <20021112.143636.55033627.davem@redhat.com>
	<200211130104.EAA09992@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211130104.EAA09992@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Wed, 13 Nov 2002 04:04:15 +0300 (MSK)

   For log: authentication signature for MD5/SHA was not truncated to conform RFC.
   
Applied, thanks.

   Side note: well, my fault, but damn common sense requires not to break
   nice good MD5 digest to some absolutely unmotivated length.

Yes, seems really stupid.
