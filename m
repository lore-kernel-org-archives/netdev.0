From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 08:43:57 -0800
Message-ID: <20071113084357.1eacf89d.randy.dunlap@oracle.com>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
	<20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<1194968001.3416.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Natalie Protasevich
 <protasnb@gmail.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-input@atrey.karlin.mff.cuni.cz,
        bugme-daemon@bugzilla.kernel.org,
        linux-scsi <linux-scsi@vger.kernel.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, mbligh@mbligh.org
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <1194968001.3416.12.camel@localhost.localdomain>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 09:33:21 -0600 James Bottomley wrote:

> On Tue, 2007-11-13 at 03:15 -0800, Andrew Morton wrote:
> > >
> > SCSI==================================================================
> > > 
> > > qla2xxx: driver initialization does not complete when booting with
> > > Port connected
> > > http://bugzilla.kernel.org/show_bug.cgi?id=9267
> > > Kernel: 2.6.23.1
> > 
> > No response from developers
> 
> Urm, well, if no-one ever tells the SCSI list it's unrealistic to expect
> anyone to be working on it.  As far as I can tell, email was sent to
> Andrew Vasquez only on 31 October. However, the fault looks to be
> generic, so he probably just dropped it.

It seems that new SCSI bugs need to be sent to linux-scsi@vger.kernel.org.

Martin, can you arrange that to happen automatically instead of
Andrew having to do it manually?

---
~Randy
