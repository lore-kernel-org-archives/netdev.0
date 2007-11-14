From: Hannes Reinecke <hare@suse.de>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 14:35:33 +0100
Message-ID: <473AF9A5.50707@suse.de>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <200711131739.45820.vda.linux@googlemail.com> <20071114072715.GO4250@stusta.de> <200711140046.20391.vda.linux@googlemail.com> <20071114133034.GR17785@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	Adrian Bunk <bunk@kernel.org>, alsa-devel@alsa-project.org,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-kernel@vger.kernel.org, protasnb@gmail.com,
	linux-ide@vger.kernel.org, Benoit Boissinot <bboissin@gmail.com>,
	Mark Lord <liml@rtr.ca>, linux-input@atrey.karlin.mff.cuni.cz,
	Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071114133034.GR17785@parisc-linux.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Wed, Nov 14, 2007 at 12:46:20AM -0700, Denys Vlasenko wrote:
>> Finally they replied and asked to rediff it against their
>> git tree. I did that and sent patches back. No reply since then.
>>
>> And mind you, the patch is not trying to do anything
>> complex, it mostly moves code around, removes 'inline',
>> adds 'const'. What should I think about it?
>=20
> I'm waiting for an ACK/NAK from Hannes, the maintainer.  What should I
> do?
>=20
I haven't actually been able to test it here (too busy, sorry). If someon=
e
else confirms it does it's job then

Acked-by: Hannes Reinecke <hare@suse.de>

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
