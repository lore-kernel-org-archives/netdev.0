From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] benet: Add missing comma between constant string
 array
Date: Sat, 09 Jul 2011 02:57:05 -0700 (PDT)
Message-ID: <20110709.025705.727560311771106736.davem@davemloft.net>
References: <cover.1310187270.git.joe@perches.com>
	<8c2d9b2ff796489a39408fade30fc93ed6040b3c.1310187270.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8c2d9b2ff796489a39408fade30fc93ed6040b3c.1310187270.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri,  8 Jul 2011 23:20:23 -0700

> Multiple quoted strings are concatenated without comma separators.
> 
> Make the arrays const while there.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
