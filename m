From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn:remove reverse_bits(), use revbit8()
Date: Mon, 10 Aug 2015 14:30:12 -0700 (PDT)
Message-ID: <20150810.143012.1342124147857318471.davem@davemloft.net>
References: <48EEE6BC-BAFE-4545-A860-237FBD1E279B@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yalin.wang2010@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <48EEE6BC-BAFE-4545-A860-237FBD1E279B@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: yalin wang <yalin.wang2010@gmail.com>
Date: Mon, 10 Aug 2015 17:15:57 +0800

> This change isdn driver, remove reverse_bits() function,
> use the generic revbit8() function instead.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Applied, however please format your Subject lines better in the
future.

There should be a space after the subsystem specifier and the ':'
character.  So "isdn: "

Then you should capitalize the description in the Subject line
because it is very much like an English sentence.
