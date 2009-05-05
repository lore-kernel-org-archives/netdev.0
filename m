From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 00/13] OF device tree handling of PHY drivers
Date: Mon, 4 May 2009 19:55:04 -0600
Message-ID: <fa686aa40905041855s22203b12ua9bce36a992fbe68@mail.gmail.com>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
	<20090427.025436.68188155.davem@davemloft.net>
	<fa686aa40904271017x726f92ffsbbc730770298766b@mail.gmail.com>
	<20090504231421.GA27541@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, afleming@freescale.com,
	David Miller <davem@davemloft.net>
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090504231421.GA27541@ld0162-tx32.am.freescale.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, May 4, 2009 at 5:14 PM, Scott Wood <scottwood@freescale.com> wrote:
> On Mon, Apr 27, 2009 at 11:17:08AM -0600, Grant Likely wrote:
>> Kumar,
>>
>> David has pulled my phylib changes into his -next tree. =A0However, some
>> of the driver changes have been compile tested only due to lack of
>> hardware. =A0Who can I ask to test the changes to the following files?
>>
>> =A0arch/powerpc/platforms/82xx/ep8248e.c =A0 =A0 | =A0 =A09 +-
>
> Tested OK.
>
>> =A0drivers/net/fs_enet/fs_enet-main.c =A0 =A0 =A0 =A0| =A0 69 +--
>> =A0drivers/net/fs_enet/mii-bitbang.c =A0 =A0 =A0 =A0 | =A0 29 +-
>
> Tested OK on pq2fads.
>
>> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 26 +-
>
> Tested on ep88xc. =A0No *new* problems. :-P

Awesome!  Thanks Scott.

g.


-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
