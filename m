From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 5/5] net: macb: Fix simple typo.
Date: Wed, 16 Mar 2016 14:51:02 +0100
Message-ID: <56E964C6.7050703@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-6-git-send-email-moritz.fischer@ettus.com>
 <56E7237A.10401@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joe@perches.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Michal Simek <michal.simek@xilinx.com>,
	Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E7237A.10401@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/03/2016 21:47, Michal Simek a =E9crit :
> On 13.3.2016 20:10, Moritz Fischer wrote:
>> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index a0c01e5..681e5bf 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -127,7 +127,7 @@ static void hw_writel(struct macb *bp, int offse=
t, u32 value)
>>  }
>> =20
>>  /* Find the CPU endianness by using the loopback bit of NCR registe=
r. When the
>> - * CPU is in big endian we need to program swaped mode for manageme=
nt
>> + * CPU is in big endian we need to program swapped mode for managem=
ent
>>   * descriptor access.
>>   */
>>  static bool hw_is_native_io(void __iomem *addr)
>>
>=20
> Remove dot at the end of subject and feel free to add my:
> Acked-by: Michal Simek <michal.simek@xilinx.com>

Yes, same for me, no dot. But anyway, here is my:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks Moritz for the patches and Michal for the reviews.

Bye,
--=20
Nicolas Ferre
