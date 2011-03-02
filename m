From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: [PATCH 0/7] Final BKL removal, take 2
Date: Wed, 02 Mar 2011 08:32:15 -0300
Message-ID: <4D6E2ABF.5040500@redhat.com>
References: <1299021191-17961-1-git-send-email-arnd@arndb.de> <20110302045923.GA28214@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Andi Kleen <ak@linux.intel.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	linux-fsdevel@vger.kernel.org, linux-x25@vger.kernel.org,
	Max Vozeler <max@vozeler.com>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org, Nick Bowler <nbowler@elliptictech.com>,
	Nick Piggin <npiggin@gmail.com>,
	Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>,
	Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110302045923.GA28214@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 02-03-2011 01:59, Greg KH escreveu:
> On Wed, Mar 02, 2011 at 12:13:04AM +0100, Arnd Bergmann wrote:
>> This is the set of patches that remain from
>> my previous submission one month ago. I've
>> dropped the ones that have either gone into
>> linux-next or got a sufficient number of
>> Acked-by:s so I put them into my own tree.
>>
>> I've updated the usbip, hpfs, ufs and appletalk
>> patches according to the feedback I got.
>>
>> If possible, I'd like the three networking patches
>> to go through the net-next tree, and the two
>> staging patches through the staging tree. I'll
>> add the other ones to my own series if I hear
>> no objections.
> 
> I'll queue up the staging patches in the staging-next tree in a day or
> so, thanks for digging them up.

Greg,

It is probably better to queue the staging/cx25821 patch via my tree, as this is one
of those staging files that it is handled via media tree. So, if it is ok
for you both, I'll get patch 2/7.

Thanks,
Mauro
