From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support for the Bosch CC770
 and Intel AN82527
Date: Thu, 01 Dec 2011 10:43:07 +0100
Message-ID: <4ED74C2B.3060305@grandegger.com>
References: <20111129.183950.1327835803051184146.davem@davemloft.net>	<4ED5CF14.4020502@hartkopp.net>	<20111130.160727.1989923062226789802.davem@davemloft.net> <20111130.161403.1880895089543477140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	boir1@yandex.ru, stanislavelensky@yahoo.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20111130.161403.1880895089543477140.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/2011 10:14 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 30 Nov 2011 16:07:27 -0500 (EST)
> 
>> I sorted this out by reverting the older changes and applying V5.
>>
>> But I had to fix things up, when applying patch #3 there are empty
>> trailing lines in some of the new files generated, and that causes
>> git to complain.
> 
> Actually, I had to revert, it doesn't even compile.  I'm really pissed
> off at how this patch set is being handled, this should never happen.
> 
> It's not damn secret how I smoke test everyone's changes, I "allmodconfig"
> and type "make".

To get that right, I just sent v6. Sorry for the pain.

Wolfgang.
