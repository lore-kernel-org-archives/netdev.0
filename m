From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:08:38 +0100 (CET)
Message-ID: <alpine.LFD.0.9999.0711131707480.3265@localhost.localdomain>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org> <4739ADA2.4060604@rtr.ca> <4739B245.9040305@rtr.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Natalie Protasevich <protasnb@gmail.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, alsa-devel@alsa-project.org,
        linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
        linux-input@atrey.karlin.mff.cuni.cz, bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <4739B245.9040305@rtr.ca>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007, Mark Lord wrote:

> Mark Lord wrote:
> > Andrew Morton wrote:
> > > On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich"
> > > <protasnb@gmail.com> wrote:
> > ..
> ..
> > > > Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=9275
> > > > Kernel: 2.6.23
> > > > This is HP notebook nc6320 T2400 945GM
> > > No response from developers
> > ..
> > 
> > I *still* get very slow resume-from-RAM quite often here
> > (new in 2.6.22 kernel, wasn't there in early 2.6.23-rc*).
> ..
> 
> Typo.  That should have said:
> 
> > (new in 2.6.23 kernel, wasn't there in early 2.6.23-rc*).

Just asked that :) Is there a chance to bisect that ?

Thanks,

	tglx
