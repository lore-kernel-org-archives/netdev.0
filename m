From: Zang Roy-r61911 <tie-fei.zang@freescale.com>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: 23 Oct 2006 10:09:23 +0800
Message-ID: <1161569363.23698.4.camel@localhost.localdomain>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>
	 <1157962200.10526.10.camel@localhost.localdomain>
	 <1158051351.14448.97.camel@localhost.localdomain>
	 <ada3bax2lzw.fsf@cisco.com>  <4506C789.4050404@pobox.com>
	 <1158749825.7973.9.camel@localhost.localdomain>
	 <45121924.4000200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"Alexandre.Bounine@tundra.com" <Alexandre.Bounine@tundra.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751172AbWJWCIx@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45121924.4000200@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-21 at 12:46, Jeff Garzik wrote:

> you should have a chip structure, that contains two structs (one for 
> each interface/port)
> 
Jeff,

I updated the code according to all your feedback and post it here

http://www.spinics.net/lists/netdev/msg17120.html

Any comment?

Roy
