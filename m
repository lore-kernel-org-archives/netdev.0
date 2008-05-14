From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 01/12] lib: create common ascii hex array
Date: Wed, 14 May 2008 12:26:10 +0100
Message-ID: <1507.1210764370@redhat.com>
References: <1210619134.24092.51.camel@brick>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-ide <linux-ide@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Jason Wessel <jason.wessel@windriver.com>,
	"ralf@linux-mips.org" <ralf@linux-mips.org>,
	Paul Mundt <lethal@linux-sh.org>,
	Paul Mackerras <paulus@samba.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1210619134.24092.51.camel@brick>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harvey Harrison <harvey.harrison@gmail.com> wrote:

> Add a common hex array in hexdump.c so everyone can use it.
> 
> Add a common hi/lo helper to avoid the shifting masking that is
> done to get the upper and lower nibbles of a byte value.
> 
> Pull the pack_hex_byte helper from kgdb as it is opencoded many
> places in the tree that will be consolidated.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Acked-by: David Howells <dhowells@redhat.com>
