From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 13:46:12 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711141343540.15844@twin.jikos.cz>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
 <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Natalie Protasevich <protasnb@gmail.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, alsa-devel@alsa-project.org,
        linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
        linux-input@atrey.karlin.mff.cuni.cz, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007, Andrew Morton wrote:

> > HID====================================================================
> > 
> > Kernel NULL pointer dereference at :usbhid:hiddev_ioctl+0x2f/0xabc
> > http://bugzilla.kernel.org/show_bug.cgi?id=9216
> > Kernel: 2.6.23.1
> > Looks like this is a regression
> No response from developers

Hi,

it is assigned to 'other_modules@kernel-bugs.osdl.org', so I didn't 
notice, it's as simple as that.

-- 
Jiri Kosina
